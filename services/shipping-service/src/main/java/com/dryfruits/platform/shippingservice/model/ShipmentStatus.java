package com.dryfruits.platform.shippingservice.model;

/**
 * Shipment Status Enumeration
 */
public enum ShipmentStatus {
    PENDING("Pending - Waiting to be processed"),
    PROCESSING("Processing - Being prepared for shipment"),
    IN_TRANSIT("In Transit - Package is on the way"),
    OUT_FOR_DELIVERY("Out for Delivery - Package is out for delivery"),
    DELIVERED("Delivered - Package has been delivered"),
    FAILED_DELIVERY("Failed Delivery - Delivery attempt failed"),
    RETURNED("Returned - Package returned to sender"),
    CANCELLED("Cancelled - Shipment was cancelled"),
    LOST("Lost - Package is lost in transit"),
    DAMAGED("Damaged - Package was damaged during transit");

    private final String description;

    ShipmentStatus(String description) {
        this.description = description;
    }

    public String getDescription() {
        return description;
    }
}