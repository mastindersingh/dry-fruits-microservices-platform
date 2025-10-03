package com.dryfruits.platform.inventoryservice.dto;

/**
 * DTO for stock availability responses
 */
public class StockAvailabilityResponse {

    private Long productId;
    private boolean available;
    private Integer availableQuantity;
    private Integer requestedQuantity;
    private String message;

    // Constructors
    public StockAvailabilityResponse() {}

    public StockAvailabilityResponse(Long productId, boolean available, Integer availableQuantity, 
                                   Integer requestedQuantity, String message) {
        this.productId = productId;
        this.available = available;
        this.availableQuantity = availableQuantity;
        this.requestedQuantity = requestedQuantity;
        this.message = message;
    }

    // Static factory methods
    public static StockAvailabilityResponse available(Long productId, Integer availableQuantity, Integer requestedQuantity) {
        return new StockAvailabilityResponse(productId, true, availableQuantity, requestedQuantity, 
                                           "Stock is available for reservation");
    }

    public static StockAvailabilityResponse unavailable(Long productId, Integer availableQuantity, Integer requestedQuantity) {
        return new StockAvailabilityResponse(productId, false, availableQuantity, requestedQuantity, 
                                           "Insufficient stock available");
    }

    // Getters and Setters
    public Long getProductId() { return productId; }
    public void setProductId(Long productId) { this.productId = productId; }

    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }

    public Integer getAvailableQuantity() { return availableQuantity; }
    public void setAvailableQuantity(Integer availableQuantity) { this.availableQuantity = availableQuantity; }

    public Integer getRequestedQuantity() { return requestedQuantity; }
    public void setRequestedQuantity(Integer requestedQuantity) { this.requestedQuantity = requestedQuantity; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
}