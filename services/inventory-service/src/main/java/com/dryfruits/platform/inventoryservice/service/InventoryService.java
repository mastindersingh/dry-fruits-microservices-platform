package com.dryfruits.platform.inventoryservice.service;

import com.dryfruits.platform.inventoryservice.model.Inventory;
import com.dryfruits.platform.inventoryservice.model.InventoryStatus;
import com.dryfruits.platform.inventoryservice.repository.InventoryRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

/**
 * Service class for managing inventory operations
 */
@Service
@Transactional
public class InventoryService {

    private static final Logger logger = LoggerFactory.getLogger(InventoryService.class);

    @Autowired
    private InventoryRepository inventoryRepository;

    /**
     * Get all inventory items
     */
    @Cacheable(value = "inventories")
    @Transactional(readOnly = true)
    public List<Inventory> getAllInventory() {
        logger.info("Fetching all inventory items");
        return inventoryRepository.findAll();
    }

    /**
     * Get inventory by ID
     */
    @Cacheable(value = "inventory", key = "#id")
    @Transactional(readOnly = true)
    public Optional<Inventory> getInventoryById(Long id) {
        logger.info("Fetching inventory with ID: {}", id);
        return inventoryRepository.findById(id);
    }

    /**
     * Get inventory by product ID and warehouse ID
     */
    @Cacheable(value = "inventory-by-product-warehouse", key = "#productId + '-' + #warehouseId")
    @Transactional(readOnly = true)
    public Optional<Inventory> getInventoryByProductAndWarehouse(Long productId, Long warehouseId) {
        logger.info("Fetching inventory for product {} in warehouse {}", productId, warehouseId);
        return inventoryRepository.findByProductIdAndWarehouseId(productId, warehouseId);
    }

    /**
     * Get all inventory for a product across all warehouses
     */
    @Cacheable(value = "inventory-by-product", key = "#productId")
    @Transactional(readOnly = true)
    public List<Inventory> getInventoryByProduct(Long productId) {
        logger.info("Fetching all inventory for product: {}", productId);
        return inventoryRepository.findByProductId(productId);
    }

    /**
     * Create new inventory item
     */
    @CacheEvict(value = {"inventories", "inventory-by-product", "inventory-by-product-warehouse"}, allEntries = true)
    public Inventory createInventory(Inventory inventory) {
        logger.info("Creating new inventory for product {} in warehouse {}", 
                   inventory.getProductId(), inventory.getWarehouseId());
        
        // Check if inventory already exists
        Optional<Inventory> existing = inventoryRepository
            .findByProductIdAndWarehouseId(inventory.getProductId(), inventory.getWarehouseId());
        
        if (existing.isPresent()) {
            throw new IllegalArgumentException("Inventory already exists for this product in this warehouse");
        }
        
        return inventoryRepository.save(inventory);
    }

    /**
     * Update inventory stock levels
     */
    @CacheEvict(value = {"inventories", "inventory-by-product", "inventory-by-product-warehouse"}, allEntries = true)
    public Inventory updateInventory(Long id, Inventory updatedInventory) {
        logger.info("Updating inventory with ID: {}", id);
        
        return inventoryRepository.findById(id)
            .map(inventory -> {
                inventory.setAvailableQuantity(updatedInventory.getAvailableQuantity());
                inventory.setMinimumStockLevel(updatedInventory.getMinimumStockLevel());
                inventory.setMaximumStockLevel(updatedInventory.getMaximumStockLevel());
                inventory.setUnitCost(updatedInventory.getUnitCost());
                inventory.setStatus(updatedInventory.getStatus());
                return inventoryRepository.save(inventory);
            })
            .orElseThrow(() -> new RuntimeException("Inventory not found with id: " + id));
    }

    /**
     * Reserve stock for an order
     */
    @CacheEvict(value = {"inventories", "inventory-by-product", "inventory-by-product-warehouse"}, allEntries = true)
    public boolean reserveStock(Long productId, Integer quantity) {
        logger.info("Attempting to reserve {} units of product {}", quantity, productId);
        
        List<Inventory> inventories = inventoryRepository.findByProductId(productId);
        
        // First check if we have enough total stock
        int totalAvailable = inventories.stream()
            .filter(inv -> inv.getStatus() == InventoryStatus.ACTIVE)
            .mapToInt(Inventory::getAvailableQuantity)
            .sum();
        
        if (totalAvailable < quantity) {
            logger.warn("Insufficient stock for product {}. Required: {}, Available: {}", 
                       productId, quantity, totalAvailable);
            return false;
        }
        
        // Reserve stock from warehouses (FIFO - first warehouse first)
        int remainingToReserve = quantity;
        for (Inventory inventory : inventories) {
            if (remainingToReserve <= 0) break;
            
            if (inventory.getStatus() == InventoryStatus.ACTIVE && inventory.getAvailableQuantity() > 0) {
                int toReserve = Math.min(remainingToReserve, inventory.getAvailableQuantity());
                inventory.reserveStock(toReserve);
                inventoryRepository.save(inventory);
                remainingToReserve -= toReserve;
                
                logger.info("Reserved {} units from warehouse {} for product {}", 
                           toReserve, inventory.getWarehouseId(), productId);
            }
        }
        
        return remainingToReserve == 0;
    }

    /**
     * Release reserved stock (cancel order)
     */
    @CacheEvict(value = {"inventories", "inventory-by-product", "inventory-by-product-warehouse"}, allEntries = true)
    public void releaseReservedStock(Long productId, Integer quantity) {
        logger.info("Releasing {} reserved units of product {}", quantity, productId);
        
        List<Inventory> inventories = inventoryRepository.findByProductId(productId);
        
        int remainingToRelease = quantity;
        for (Inventory inventory : inventories) {
            if (remainingToRelease <= 0) break;
            
            if (inventory.getReservedQuantity() > 0) {
                int toRelease = Math.min(remainingToRelease, inventory.getReservedQuantity());
                inventory.releaseReservedStock(toRelease);
                inventoryRepository.save(inventory);
                remainingToRelease -= toRelease;
                
                logger.info("Released {} reserved units from warehouse {} for product {}", 
                           toRelease, inventory.getWarehouseId(), productId);
            }
        }
    }

    /**
     * Confirm sale (convert reserved to sold)
     */
    @CacheEvict(value = {"inventories", "inventory-by-product", "inventory-by-product-warehouse"}, allEntries = true)
    public void confirmSale(Long productId, Integer quantity) {
        logger.info("Confirming sale of {} units for product {}", quantity, productId);
        
        List<Inventory> inventories = inventoryRepository.findByProductId(productId);
        
        int remainingToConfirm = quantity;
        for (Inventory inventory : inventories) {
            if (remainingToConfirm <= 0) break;
            
            if (inventory.getReservedQuantity() > 0) {
                int toConfirm = Math.min(remainingToConfirm, inventory.getReservedQuantity());
                inventory.confirmSale(toConfirm);
                inventoryRepository.save(inventory);
                remainingToConfirm -= toConfirm;
                
                logger.info("Confirmed sale of {} units from warehouse {} for product {}", 
                           toConfirm, inventory.getWarehouseId(), productId);
            }
        }
    }

    /**
     * Get low stock items
     */
    @Cacheable(value = "low-stock-items")
    @Transactional(readOnly = true)
    public List<Inventory> getLowStockItems() {
        logger.info("Fetching low stock items");
        return inventoryRepository.findLowStockItems();
    }

    /**
     * Get out of stock items
     */
    @Cacheable(value = "out-of-stock-items")
    @Transactional(readOnly = true)
    public List<Inventory> getOutOfStockItems() {
        logger.info("Fetching out of stock items");
        return inventoryRepository.findOutOfStockItems();
    }

    /**
     * Check if product has sufficient stock
     */
    @Transactional(readOnly = true)
    public boolean hasAvailableStock(Long productId, Integer requiredQuantity) {
        logger.info("Checking stock availability for product {} (required: {})", productId, requiredQuantity);
        Boolean hasStock = inventoryRepository.hasAvailableStock(productId, requiredQuantity);
        return hasStock != null && hasStock;
    }

    /**
     * Get total available quantity for a product
     */
    @Transactional(readOnly = true)
    public Integer getTotalAvailableQuantity(Long productId) {
        return inventoryRepository.getTotalAvailableQuantityByProductId(productId);
    }

    /**
     * Delete inventory item
     */
    @CacheEvict(value = {"inventories", "inventory-by-product", "inventory-by-product-warehouse"}, allEntries = true)
    public void deleteInventory(Long id) {
        logger.info("Deleting inventory with ID: {}", id);
        inventoryRepository.deleteById(id);
    }

    /**
     * Search inventory by product name
     */
    @Transactional(readOnly = true)
    public List<Inventory> searchByProductName(String productName) {
        logger.info("Searching inventory by product name: {}", productName);
        return inventoryRepository.findByProductNameContainingIgnoreCase(productName);
    }
}