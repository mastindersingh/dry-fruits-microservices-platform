package com.dryfruits.platform.inventoryservice.controller;

import com.dryfruits.platform.inventoryservice.dto.StockAvailabilityResponse;
import com.dryfruits.platform.inventoryservice.dto.StockReservationRequest;
import com.dryfruits.platform.inventoryservice.model.Inventory;
import com.dryfruits.platform.inventoryservice.service.InventoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * REST Controller for Inventory Management
 * Provides endpoints for managing product inventory and stock operations
 */
@RestController
@RequestMapping("/api/inventory")
@Tag(name = "Inventory Management", description = "APIs for managing product inventory and stock operations")
@CrossOrigin(origins = "*")
public class InventoryController {

    private static final Logger logger = LoggerFactory.getLogger(InventoryController.class);

    @Autowired
    private InventoryService inventoryService;

    /**
     * Get all inventory items
     */
    @GetMapping
    @Operation(summary = "Get all inventory items", description = "Retrieve all inventory items across all warehouses")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved inventory items")
    public ResponseEntity<List<Inventory>> getAllInventory() {
        logger.info("Request to get all inventory items");
        List<Inventory> inventories = inventoryService.getAllInventory();
        return ResponseEntity.ok(inventories);
    }

    /**
     * Get inventory by ID
     */
    @GetMapping("/{id}")
    @Operation(summary = "Get inventory by ID", description = "Retrieve a specific inventory item by its ID")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Successfully retrieved inventory item"),
        @ApiResponse(responseCode = "404", description = "Inventory item not found")
    })
    public ResponseEntity<Inventory> getInventoryById(
            @Parameter(description = "Inventory ID") @PathVariable Long id) {
        logger.info("Request to get inventory with ID: {}", id);
        Optional<Inventory> inventory = inventoryService.getInventoryById(id);
        return inventory.map(ResponseEntity::ok)
                       .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Get inventory by product ID
     */
    @GetMapping("/product/{productId}")
    @Operation(summary = "Get inventory by product ID", description = "Retrieve all inventory for a specific product across all warehouses")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved product inventory")
    public ResponseEntity<List<Inventory>> getInventoryByProduct(
            @Parameter(description = "Product ID") @PathVariable Long productId) {
        logger.info("Request to get inventory for product: {}", productId);
        List<Inventory> inventories = inventoryService.getInventoryByProduct(productId);
        return ResponseEntity.ok(inventories);
    }

    /**
     * Create new inventory item
     */
    @PostMapping
    @Operation(summary = "Create new inventory", description = "Create a new inventory item for a product in a warehouse")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Successfully created inventory item"),
        @ApiResponse(responseCode = "400", description = "Invalid input data"),
        @ApiResponse(responseCode = "409", description = "Inventory already exists for this product in this warehouse")
    })
    public ResponseEntity<Inventory> createInventory(@Valid @RequestBody Inventory inventory) {
        logger.info("Request to create inventory for product {} in warehouse {}", 
                   inventory.getProductId(), inventory.getWarehouseId());
        try {
            Inventory createdInventory = inventoryService.createInventory(inventory);
            return ResponseEntity.status(HttpStatus.CREATED).body(createdInventory);
        } catch (IllegalArgumentException e) {
            logger.error("Error creating inventory: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.CONFLICT).build();
        }
    }

    /**
     * Update inventory item
     */
    @PutMapping("/{id}")
    @Operation(summary = "Update inventory", description = "Update an existing inventory item")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Successfully updated inventory item"),
        @ApiResponse(responseCode = "404", description = "Inventory item not found"),
        @ApiResponse(responseCode = "400", description = "Invalid input data")
    })
    public ResponseEntity<Inventory> updateInventory(
            @Parameter(description = "Inventory ID") @PathVariable Long id,
            @Valid @RequestBody Inventory inventory) {
        logger.info("Request to update inventory with ID: {}", id);
        try {
            Inventory updatedInventory = inventoryService.updateInventory(id, inventory);
            return ResponseEntity.ok(updatedInventory);
        } catch (RuntimeException e) {
            logger.error("Error updating inventory: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }

    /**
     * Check stock availability for a product
     */
    @GetMapping("/availability/{productId}/{quantity}")
    @Operation(summary = "Check stock availability", description = "Check if sufficient stock is available for a product")
    @ApiResponse(responseCode = "200", description = "Successfully checked stock availability")
    public ResponseEntity<StockAvailabilityResponse> checkStockAvailability(
            @Parameter(description = "Product ID") @PathVariable Long productId,
            @Parameter(description = "Required quantity") @PathVariable Integer quantity) {
        logger.info("Request to check stock availability for product {} (quantity: {})", productId, quantity);
        
        Integer availableQuantity = inventoryService.getTotalAvailableQuantity(productId);
        boolean hasStock = inventoryService.hasAvailableStock(productId, quantity);
        
        StockAvailabilityResponse response = hasStock ? 
            StockAvailabilityResponse.available(productId, availableQuantity, quantity) :
            StockAvailabilityResponse.unavailable(productId, availableQuantity, quantity);
            
        return ResponseEntity.ok(response);
    }

    /**
     * Reserve stock for an order
     */
    @PostMapping("/reserve")
    @Operation(summary = "Reserve stock", description = "Reserve stock for an order")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Successfully reserved stock"),
        @ApiResponse(responseCode = "400", description = "Insufficient stock available")
    })
    public ResponseEntity<String> reserveStock(@Valid @RequestBody StockReservationRequest request) {
        logger.info("Request to reserve {} units of product {} for order {}", 
                   request.getQuantity(), request.getProductId(), request.getOrderId());
        
        boolean reserved = inventoryService.reserveStock(request.getProductId(), request.getQuantity());
        
        if (reserved) {
            return ResponseEntity.ok("Stock reserved successfully");
        } else {
            return ResponseEntity.badRequest().body("Insufficient stock available");
        }
    }

    /**
     * Release reserved stock (cancel order)
     */
    @PostMapping("/release")
    @Operation(summary = "Release reserved stock", description = "Release previously reserved stock")
    @ApiResponse(responseCode = "200", description = "Successfully released reserved stock")
    public ResponseEntity<String> releaseReservedStock(@Valid @RequestBody StockReservationRequest request) {
        logger.info("Request to release {} reserved units of product {} for order {}", 
                   request.getQuantity(), request.getProductId(), request.getOrderId());
        
        inventoryService.releaseReservedStock(request.getProductId(), request.getQuantity());
        return ResponseEntity.ok("Reserved stock released successfully");
    }

    /**
     * Confirm sale (convert reserved to sold)
     */
    @PostMapping("/confirm-sale")
    @Operation(summary = "Confirm sale", description = "Confirm sale and convert reserved stock to sold")
    @ApiResponse(responseCode = "200", description = "Successfully confirmed sale")
    public ResponseEntity<String> confirmSale(@Valid @RequestBody StockReservationRequest request) {
        logger.info("Request to confirm sale of {} units of product {} for order {}", 
                   request.getQuantity(), request.getProductId(), request.getOrderId());
        
        inventoryService.confirmSale(request.getProductId(), request.getQuantity());
        return ResponseEntity.ok("Sale confirmed successfully");
    }

    /**
     * Get low stock items
     */
    @GetMapping("/low-stock")
    @Operation(summary = "Get low stock items", description = "Retrieve all items with low stock levels")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved low stock items")
    public ResponseEntity<List<Inventory>> getLowStockItems() {
        logger.info("Request to get low stock items");
        List<Inventory> lowStockItems = inventoryService.getLowStockItems();
        return ResponseEntity.ok(lowStockItems);
    }

    /**
     * Get out of stock items
     */
    @GetMapping("/out-of-stock")
    @Operation(summary = "Get out of stock items", description = "Retrieve all items that are out of stock")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved out of stock items")
    public ResponseEntity<List<Inventory>> getOutOfStockItems() {
        logger.info("Request to get out of stock items");
        List<Inventory> outOfStockItems = inventoryService.getOutOfStockItems();
        return ResponseEntity.ok(outOfStockItems);
    }

    /**
     * Search inventory by product name
     */
    @GetMapping("/search")
    @Operation(summary = "Search inventory", description = "Search inventory by product name")
    @ApiResponse(responseCode = "200", description = "Successfully retrieved search results")
    public ResponseEntity<List<Inventory>> searchInventory(
            @Parameter(description = "Product name to search") @RequestParam String productName) {
        logger.info("Request to search inventory by product name: {}", productName);
        List<Inventory> results = inventoryService.searchByProductName(productName);
        return ResponseEntity.ok(results);
    }

    /**
     * Delete inventory item
     */
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete inventory", description = "Delete an inventory item")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "204", description = "Successfully deleted inventory item"),
        @ApiResponse(responseCode = "404", description = "Inventory item not found")
    })
    public ResponseEntity<Void> deleteInventory(
            @Parameter(description = "Inventory ID") @PathVariable Long id) {
        logger.info("Request to delete inventory with ID: {}", id);
        try {
            inventoryService.deleteInventory(id);
            return ResponseEntity.noContent().build();
        } catch (Exception e) {
            logger.error("Error deleting inventory: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }
}