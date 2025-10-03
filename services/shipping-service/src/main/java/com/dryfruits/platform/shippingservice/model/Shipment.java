package com.dryfruits.platform.shippingservice.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Shipment Entity representing a shipment record
 */
@Entity
@Table(name = "shipments",
       indexes = {
           @Index(name = "idx_order_id", columnList = "order_id"),
           @Index(name = "idx_tracking_number", columnList = "tracking_number"),
           @Index(name = "idx_status", columnList = "status")
       })
public class Shipment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_id", nullable = false)
    @NotNull(message = "Order ID is required")
    private Long orderId;

    @Column(name = "tracking_number", unique = true)
    private String trackingNumber;

    @Column(name = "carrier", nullable = false)
    @NotBlank(message = "Carrier is required")
    private String carrier;

    @Column(name = "service_type", nullable = false)
    @NotBlank(message = "Service type is required")
    private String serviceType;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private ShipmentStatus status = ShipmentStatus.PENDING;

    // Shipping addresses
    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "name", column = @Column(name = "sender_name")),
        @AttributeOverride(name = "addressLine1", column = @Column(name = "sender_address_line1")),
        @AttributeOverride(name = "addressLine2", column = @Column(name = "sender_address_line2")),
        @AttributeOverride(name = "city", column = @Column(name = "sender_city")),
        @AttributeOverride(name = "state", column = @Column(name = "sender_state")),
        @AttributeOverride(name = "zipCode", column = @Column(name = "sender_zip_code")),
        @AttributeOverride(name = "country", column = @Column(name = "sender_country")),
        @AttributeOverride(name = "phone", column = @Column(name = "sender_phone"))
    })
    private Address senderAddress;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "name", column = @Column(name = "recipient_name")),
        @AttributeOverride(name = "addressLine1", column = @Column(name = "recipient_address_line1")),
        @AttributeOverride(name = "addressLine2", column = @Column(name = "recipient_address_line2")),
        @AttributeOverride(name = "city", column = @Column(name = "recipient_city")),
        @AttributeOverride(name = "state", column = @Column(name = "recipient_state")),
        @AttributeOverride(name = "zipCode", column = @Column(name = "recipient_zip_code")),
        @AttributeOverride(name = "country", column = @Column(name = "recipient_country")),
        @AttributeOverride(name = "phone", column = @Column(name = "recipient_phone"))
    })
    private Address recipientAddress;

    // Package details
    @Column(name = "weight", precision = 10, scale = 2)
    @Positive(message = "Weight must be positive")
    private BigDecimal weight;

    @Column(name = "length", precision = 10, scale = 2)
    private BigDecimal length;

    @Column(name = "width", precision = 10, scale = 2)
    private BigDecimal width;

    @Column(name = "height", precision = 10, scale = 2)
    private BigDecimal height;

    // Cost information
    @Column(name = "shipping_cost", precision = 10, scale = 2)
    private BigDecimal shippingCost;

    @Column(name = "insurance_amount", precision = 10, scale = 2)
    private BigDecimal insuranceAmount;

    // Delivery information
    @Column(name = "estimated_delivery_date")
    private LocalDateTime estimatedDeliveryDate;

    @Column(name = "actual_delivery_date")
    private LocalDateTime actualDeliveryDate;

    @Column(name = "delivery_instructions", length = 500)
    private String deliveryInstructions;

    @Column(name = "signature_required")
    private Boolean signatureRequired = false;

    // Timestamps
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Column(name = "shipped_at")
    private LocalDateTime shippedAt;

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
    public Shipment() {}

    public Shipment(Long orderId, String carrier, String serviceType, Address senderAddress, Address recipientAddress) {
        this.orderId = orderId;
        this.carrier = carrier;
        this.serviceType = serviceType;
        this.senderAddress = senderAddress;
        this.recipientAddress = recipientAddress;
    }

    // Business methods
    public boolean isDelivered() {
        return status == ShipmentStatus.DELIVERED;
    }

    public boolean isInTransit() {
        return status == ShipmentStatus.IN_TRANSIT;
    }

    public boolean canBeCancelled() {
        return status == ShipmentStatus.PENDING || status == ShipmentStatus.PROCESSING;
    }

    public void ship() {
        if (status != ShipmentStatus.PROCESSING) {
            throw new IllegalStateException("Shipment must be in PROCESSING status to ship");
        }
        this.status = ShipmentStatus.IN_TRANSIT;
        this.shippedAt = LocalDateTime.now();
    }

    public void deliver() {
        if (status != ShipmentStatus.IN_TRANSIT && status != ShipmentStatus.OUT_FOR_DELIVERY) {
            throw new IllegalStateException("Shipment must be in transit or out for delivery to be delivered");
        }
        this.status = ShipmentStatus.DELIVERED;
        this.actualDeliveryDate = LocalDateTime.now();
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getOrderId() { return orderId; }
    public void setOrderId(Long orderId) { this.orderId = orderId; }

    public String getTrackingNumber() { return trackingNumber; }
    public void setTrackingNumber(String trackingNumber) { this.trackingNumber = trackingNumber; }

    public String getCarrier() { return carrier; }
    public void setCarrier(String carrier) { this.carrier = carrier; }

    public String getServiceType() { return serviceType; }
    public void setServiceType(String serviceType) { this.serviceType = serviceType; }

    public ShipmentStatus getStatus() { return status; }
    public void setStatus(ShipmentStatus status) { this.status = status; }

    public Address getSenderAddress() { return senderAddress; }
    public void setSenderAddress(Address senderAddress) { this.senderAddress = senderAddress; }

    public Address getRecipientAddress() { return recipientAddress; }
    public void setRecipientAddress(Address recipientAddress) { this.recipientAddress = recipientAddress; }

    public BigDecimal getWeight() { return weight; }
    public void setWeight(BigDecimal weight) { this.weight = weight; }

    public BigDecimal getLength() { return length; }
    public void setLength(BigDecimal length) { this.length = length; }

    public BigDecimal getWidth() { return width; }
    public void setWidth(BigDecimal width) { this.width = width; }

    public BigDecimal getHeight() { return height; }
    public void setHeight(BigDecimal height) { this.height = height; }

    public BigDecimal getShippingCost() { return shippingCost; }
    public void setShippingCost(BigDecimal shippingCost) { this.shippingCost = shippingCost; }

    public BigDecimal getInsuranceAmount() { return insuranceAmount; }
    public void setInsuranceAmount(BigDecimal insuranceAmount) { this.insuranceAmount = insuranceAmount; }

    public LocalDateTime getEstimatedDeliveryDate() { return estimatedDeliveryDate; }
    public void setEstimatedDeliveryDate(LocalDateTime estimatedDeliveryDate) { this.estimatedDeliveryDate = estimatedDeliveryDate; }

    public LocalDateTime getActualDeliveryDate() { return actualDeliveryDate; }
    public void setActualDeliveryDate(LocalDateTime actualDeliveryDate) { this.actualDeliveryDate = actualDeliveryDate; }

    public String getDeliveryInstructions() { return deliveryInstructions; }
    public void setDeliveryInstructions(String deliveryInstructions) { this.deliveryInstructions = deliveryInstructions; }

    public Boolean getSignatureRequired() { return signatureRequired; }
    public void setSignatureRequired(Boolean signatureRequired) { this.signatureRequired = signatureRequired; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public LocalDateTime getShippedAt() { return shippedAt; }
    public void setShippedAt(LocalDateTime shippedAt) { this.shippedAt = shippedAt; }
}