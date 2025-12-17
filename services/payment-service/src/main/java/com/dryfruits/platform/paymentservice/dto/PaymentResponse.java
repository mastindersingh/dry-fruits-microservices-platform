package com.dryfruits.platform.paymentservice.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class PaymentResponse {
    
    private Long paymentId;
    private Long orderId;
    private String status; // COMPLETED, FAILED, PROCESSING
    private String transactionId;
    private BigDecimal amount;
    private String currency;
    private String cardLast4;
    private String cardBrand;
    private String failureReason;
    private LocalDateTime createdAt;
    private String message;
    
    // Success constructor
    public PaymentResponse(Long paymentId, Long orderId, String transactionId, BigDecimal amount, 
                          String currency, String cardLast4, String cardBrand, String message) {
        this.paymentId = paymentId;
        this.orderId = orderId;
        this.status = "COMPLETED";
        this.transactionId = transactionId;
        this.amount = amount;
        this.currency = currency;
        this.cardLast4 = cardLast4;
        this.cardBrand = cardBrand;
        this.createdAt = LocalDateTime.now();
        this.message = message;
    }
    
    // Failure constructor
    public PaymentResponse(Long paymentId, Long orderId, BigDecimal amount, String failureReason) {
        this.paymentId = paymentId;
        this.orderId = orderId;
        this.status = "FAILED";
        this.amount = amount;
        this.failureReason = failureReason;
        this.createdAt = LocalDateTime.now();
        this.message = "Payment failed";
    }
    
    // Getters and Setters
    public Long getPaymentId() {
        return paymentId;
    }
    
    public void setPaymentId(Long paymentId) {
        this.paymentId = paymentId;
    }
    
    public Long getOrderId() {
        return orderId;
    }
    
    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public String getTransactionId() {
        return transactionId;
    }
    
    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }
    
    public BigDecimal getAmount() {
        return amount;
    }
    
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }
    
    public String getCurrency() {
        return currency;
    }
    
    public void setCurrency(String currency) {
        this.currency = currency;
    }
    
    public String getCardLast4() {
        return cardLast4;
    }
    
    public void setCardLast4(String cardLast4) {
        this.cardLast4 = cardLast4;
    }
    
    public String getCardBrand() {
        return cardBrand;
    }
    
    public void setCardBrand(String cardBrand) {
        this.cardBrand = cardBrand;
    }
    
    public String getFailureReason() {
        return failureReason;
    }
    
    public void setFailureReason(String failureReason) {
        this.failureReason = failureReason;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
}
