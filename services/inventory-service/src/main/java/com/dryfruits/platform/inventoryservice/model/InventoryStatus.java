package com.dryfruits.platform.inventoryservice.model;

/**
 * Inventory Status Enumeration
 */
public enum InventoryStatus {
    ACTIVE("Active - Available for sale"),
    INACTIVE("Inactive - Not available for sale"),
    DISCONTINUED("Discontinued - Product no longer sold"),
    DAMAGED("Damaged - Stock is damaged"),
    EXPIRED("Expired - Stock has expired"),
    QUARANTINE("Quarantine - Under quality review");

    private final String description;

    InventoryStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}