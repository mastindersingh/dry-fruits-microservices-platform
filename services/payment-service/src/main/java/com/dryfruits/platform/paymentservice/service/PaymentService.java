package com.dryfruits.platform.paymentservice.service;

import com.dryfruits.platform.paymentservice.dto.PaymentRequest;
import com.dryfruits.platform.paymentservice.dto.PaymentResponse;
import com.dryfruits.platform.paymentservice.model.Payment;
import com.dryfruits.platform.paymentservice.repository.PaymentRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.UUID;

@Service
public class PaymentService {
    
    private static final Logger logger = LoggerFactory.getLogger(PaymentService.class);
    
    @Autowired
    private PaymentRepository paymentRepository;
    
    /**
     * Process a payment (Mock implementation)
     * Test Card Numbers:
     * - 4111111111111111 (Visa) - Always succeeds
     * - 4000000000000002 (Visa) - Always fails (insufficient funds)
     * - 5555555555554444 (Mastercard) - Always succeeds
     * - 378282246310005 (Amex) - Always succeeds
     * - 4000000000009995 (Visa) - Fails with declined
     */
    @Transactional
    public PaymentResponse processPayment(PaymentRequest request) {
        logger.info("Processing payment for order: {}, amount: {}", request.getOrderId(), request.getAmount());
        
        // Create payment record
        Payment payment = new Payment();
        payment.setOrderId(request.getOrderId());
        payment.setUserId(request.getUserId());
        payment.setAmount(request.getAmount());
        payment.setCurrency(request.getCurrency());
        payment.setStatus(Payment.PaymentStatus.PROCESSING);
        
        try {
            payment.setMethod(Payment.PaymentMethod.valueOf(request.getPaymentMethod().toUpperCase()));
        } catch (IllegalArgumentException e) {
            payment.setMethod(Payment.PaymentMethod.CREDIT_CARD);
        }
        
        // Validate card
        String cardNumber = request.getCardNumber();
        String cardBrand = detectCardBrand(cardNumber);
        payment.setCardBrand(cardBrand);
        payment.setCardLast4(cardNumber.substring(cardNumber.length() - 4));
        
        // Validate expiry date
        if (!isCardExpired(request.getExpiryMonth(), request.getExpiryYear())) {
            // Mock payment processing based on test card numbers
            boolean paymentSuccess = processPaymentWithGateway(cardNumber, request.getCvv());
            
            if (paymentSuccess) {
                // Success
                String transactionId = generateTransactionId();
                payment.setTransactionId(transactionId);
                payment.setStatus(Payment.PaymentStatus.COMPLETED);
                
                payment = paymentRepository.save(payment);
                
                logger.info("Payment successful for order: {}, transaction: {}", request.getOrderId(), transactionId);
                
                return new PaymentResponse(
                    payment.getId(),
                    payment.getOrderId(),
                    transactionId,
                    payment.getAmount(),
                    payment.getCurrency(),
                    payment.getCardLast4(),
                    payment.getCardBrand(),
                    "Payment processed successfully"
                );
            } else {
                // Failed
                payment.setStatus(Payment.PaymentStatus.FAILED);
                payment.setFailureReason("Card declined - Insufficient funds");
                
                payment = paymentRepository.save(payment);
                
                logger.warn("Payment failed for order: {}", request.getOrderId());
                
                return new PaymentResponse(
                    payment.getId(),
                    payment.getOrderId(),
                    payment.getAmount(),
                    "Card declined - Insufficient funds"
                );
            }
        } else {
            // Card expired
            payment.setStatus(Payment.PaymentStatus.FAILED);
            payment.setFailureReason("Card expired");
            
            payment = paymentRepository.save(payment);
            
            logger.warn("Payment failed - Card expired for order: {}", request.getOrderId());
            
            return new PaymentResponse(
                payment.getId(),
                payment.getOrderId(),
                payment.getAmount(),
                "Card expired"
            );
        }
    }
    
    /**
     * Mock payment gateway processing
     * Test card logic:
     * - Cards ending in 1111 or 4444 or 0005 -> Success
     * - Cards ending in 0002 or 9995 -> Failure
     */
    private boolean processPaymentWithGateway(String cardNumber, String cvv) {
        // Simulate processing delay
        try {
            Thread.sleep(1000); // 1 second delay
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        
        // Test card logic
        if (cardNumber.endsWith("1111") || cardNumber.endsWith("4444") || cardNumber.endsWith("0005")) {
            return true; // Success
        } else if (cardNumber.endsWith("0002") || cardNumber.endsWith("9995")) {
            return false; // Failure
        }
        
        // For other cards, random success (80% success rate)
        return Math.random() < 0.8;
    }
    
    /**
     * Detect card brand based on card number
     */
    private String detectCardBrand(String cardNumber) {
        if (cardNumber.startsWith("4")) {
            return "Visa";
        } else if (cardNumber.startsWith("5")) {
            return "Mastercard";
        } else if (cardNumber.startsWith("37") || cardNumber.startsWith("34")) {
            return "American Express";
        } else if (cardNumber.startsWith("6")) {
            return "Discover";
        }
        return "Unknown";
    }
    
    /**
     * Check if card is expired
     */
    private boolean isCardExpired(String expiryMonth, String expiryYear) {
        try {
            int month = Integer.parseInt(expiryMonth);
            int year = Integer.parseInt(expiryYear);
            
            LocalDate now = LocalDate.now();
            LocalDate expiryDate = LocalDate.of(year, month, 1).plusMonths(1).minusDays(1);
            
            return expiryDate.isBefore(now);
        } catch (Exception e) {
            return true; // Treat invalid date as expired
        }
    }
    
    /**
     * Generate a unique transaction ID
     */
    private String generateTransactionId() {
        return "TXN-" + UUID.randomUUID().toString().substring(0, 18).toUpperCase();
    }
    
    /**
     * Get payment by ID
     */
    public Payment getPaymentById(Long id) {
        return paymentRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Payment not found with id: " + id));
    }
    
    /**
     * Get payment by order ID
     */
    public Payment getPaymentByOrderId(Long orderId) {
        return paymentRepository.findByOrderId(orderId)
            .orElseThrow(() -> new RuntimeException("Payment not found for order: " + orderId));
    }
}
