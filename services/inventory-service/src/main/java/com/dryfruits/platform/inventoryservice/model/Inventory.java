package com.dryfruits.platform.inventoryservice.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.time.LocalDateTime;
@Entity
@Table(name = "inventory", 
       indexes = {
           @Index(name = "idx_product_id", columnList = "product_id"),
           @Index(name = "idx_warehouse_id", columnList = "warehouse_id")
       })
public class Inventory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "product_id", nullable = false)
    @NotNull(message = "Product ID is required")
    private Long productId;

    @Column(name = "product_name", nullable = false)
    @NotBlank(message = "Product name is required")
    private String productName;

    @Column(name = "warehouse_id", nullable = false)
    @NotNull(message = "Warehouse ID is required")
    private Long warehouseId;

    @Column(name = "warehouse_name", nullable = false)
    @NotBlank(message = "Warehouse name is required")
    private String warehouseName;

    @Column(name = "available_quantity", nullable = false)
    @Min(value = 0, message = "Available quantity cannot be negative")
    private Integer availableQuantity;

    @Column(name = "reserved_quantity", nullable = false)
    @Min(value = 0, message = "Reserved quantity cannot be negative")
    private Integer reservedQuantity;

    @Column(name = "minimum_stock_level", nullable = false)
    @Min(value = 0, message = "Minimum stock level cannot be negative")
    private Integer minimumStockLevel;

    @Column(name = "maximum_stock_level", nullable = false)
    @Min(value = 0, message = "Maximum stock level cannot be negative")
    private Integer maximumStockLevel;

    @Column(name = "unit_cost")
    private Double unitCost;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private InventoryStatus status = InventoryStatus.ACTIVE;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    // Constructors
    public Inventory() {}

    public Inventory(Long productId, String productName, Long warehouseId, 
                    String warehouseName, Integer availableQuantity, 
                    Integer minimumStockLevel, Integer maximumStockLevel) {
        this.productId = productId;
        this.productName = productName;
        this.warehouseId = warehouseId;
        this.warehouseName = warehouseName;
        this.availableQuantity = availableQuantity;
        this.reservedQuantity = 0;
        this.minimumStockLevel = minimumStockLevel;
        this.maximumStockLevel = maximumStockLevel;
    }

    // Business methods
    public boolean isLowStock() {
        return availableQuantity <= minimumStockLevel;
    }

    public boolean isOutOfStock() {
        return availableQuantity <= 0;
    }

    public Integer getTotalQuantity() {
        return availableQuantity + reservedQuantity;
    }

    public boolean canReserve(Integer quantity) {
        return availableQuantity >= quantity;
    }

    public void reserveStock(Integer quantity) {
        if (!canReserve(quantity)) {
            throw new IllegalArgumentException("Insufficient stock to reserve");
        }
        this.availableQuantity -= quantity;
        this.reservedQuantity += quantity;
    }

    public void releaseReservedStock(Integer quantity) {
        if (reservedQuantity < quantity) {
            throw new IllegalArgumentException("Cannot release more than reserved");
        }
        this.reservedQuantity -= quantity;
        this.availableQuantity += quantity;
    }

    public void confirmSale(Integer quantity) {
        if (reservedQuantity < quantity) {
            throw new IllegalArgumentException("Cannot confirm sale for more than reserved");
        }
        this.reservedQuantity -= quantity;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public String getProductName() { return productName; }
    public void setProductName(String productName) { this.productName = productName; }

    public Long getWarehouseId() { return warehouseId; }
    public void setWarehouseId(Long warehouseId) { this.warehouseId = warehouseId; }

    public String getWarehouseName() { return warehouseName; }
    public void setWarehouseName(String warehouseName) { this.warehouseName = warehouseName; }

    public Integer getAvailableQuantity() { return availableQuantity; }
    public void setAvailableQuantity(Integer availableQuantity) { this.availableQuantity = availableQuantity; }

    public Integer getReservedQuantity() { return reservedQuantity; }
    public void setReservedQuantity(Integer reservedQuantity) { this.reservedQuantity = reservedQuantity; }

    public Integer getMinimumStockLevel() { return minimumStockLevel; }
    public void setMinimumStockLevel(Integer minimumStockLevel) { this.minimumStockLevel = minimumStockLevel; }

    public Integer getMaximumStockLevel() { return maximumStockLevel; }
    public void setMaximumStockLevel(Integer maximumStockLevel) { this.maximumStockLevel = maximumStockLevel; }

    public Double getUnitCost() { return unitCost; }
    public void setUnitCost(Double unitCost) { this.unitCost = unitCost; }

    public InventoryStatus getStatus() { return status; }
    public void setStatus(InventoryStatus status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}