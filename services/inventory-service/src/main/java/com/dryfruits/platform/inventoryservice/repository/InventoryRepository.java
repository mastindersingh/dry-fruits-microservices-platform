package com.dryfruits.platform.inventoryservice.repository;

import com.dryfruits.platform.inventoryservice.model.Inventory;
import com.dryfruits.platform.inventoryservice.model.InventoryStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Repository interface for Inventory entity
 */
@Repository
public interface InventoryRepository extends JpaRepository<Inventory, Long> {

    /**
     * Find inventory by product ID and warehouse ID
     */
    Optional<Inventory> findByProductIdAndWarehouseId(Long productId, Long warehouseId);

    /**
     * Find all inventory for a specific product across all warehouses
     */
    List<Inventory> findByProductId(Long productId);

    /**
     * Find all inventory for a specific warehouse
     */
    List<Inventory> findByWarehouseId(Long warehouseId);

    /**
     * Find all products with low stock (available quantity <= minimum stock level)
     */
    @Query("SELECT i FROM Inventory i WHERE i.availableQuantity <= i.minimumStockLevel AND i.status = 'ACTIVE'")
    List<Inventory> findLowStockItems();

    /**
     * Find all out of stock products
     */
    @Query("SELECT i FROM Inventory i WHERE i.availableQuantity = 0 AND i.status = 'ACTIVE'")
    List<Inventory> findOutOfStockItems();

    /**
     * Find inventory by status
     */
    List<Inventory> findByStatus(InventoryStatus status);

    /**
     * Get total available quantity for a product across all warehouses
     */
    @Query("SELECT COALESCE(SUM(i.availableQuantity), 0) FROM Inventory i WHERE i.productId = :productId AND i.status = 'ACTIVE'")
    Integer getTotalAvailableQuantityByProductId(@Param("productId") Long productId);

    /**
     * Get total reserved quantity for a product across all warehouses
     */
    @Query("SELECT COALESCE(SUM(i.reservedQuantity), 0) FROM Inventory i WHERE i.productId = :productId AND i.status = 'ACTIVE'")
    Integer getTotalReservedQuantityByProductId(@Param("productId") Long productId);

    /**
     * Check if product has sufficient stock across all warehouses
     */
    @Query("SELECT CASE WHEN SUM(i.availableQuantity) >= :requiredQuantity THEN true ELSE false END " +
           "FROM Inventory i WHERE i.productId = :productId AND i.status = 'ACTIVE'")
    Boolean hasAvailableStock(@Param("productId") Long productId, @Param("requiredQuantity") Integer requiredQuantity);

    /**
     * Find products by name pattern (for search functionality)
     */
    @Query("SELECT i FROM Inventory i WHERE LOWER(i.productName) LIKE LOWER(CONCAT('%', :productName, '%')) AND i.status = 'ACTIVE'")
    List<Inventory> findByProductNameContainingIgnoreCase(@Param("productName") String productName);

    /**
     * Find all active inventory items
     */
    @Query("SELECT i FROM Inventory i WHERE i.status = 'ACTIVE'")
    List<Inventory> findAllActiveInventory();
}