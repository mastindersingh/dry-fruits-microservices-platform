# 🎯 **Adding Business Logic to Your Microservices**

## 💡 **Yes, You Can Add Rich Business Logic!**

Your services are **Spring Boot applications** with full business capability. Here are examples:

## 🏪 **Inventory Service Business Logic Examples:**

### **1. Smart Restocking Algorithm:**
```java
// In InventoryService.java
@Service
public class SmartRestockingService {
    
    @Scheduled(fixedRate = 300000) // Every 5 minutes
    public void checkRestockingNeeds() {
        List<Inventory> lowStockItems = inventoryRepository.findLowStockItems();
        
        for (Inventory item : lowStockItems) {
            // Business logic: Calculate reorder quantity
            int reorderQuantity = calculateOptimalReorderQuantity(item);
            
            // Business logic: Check supplier availability
            if (isSupplierAvailable(item.getProductId())) {
                createPurchaseOrder(item.getProductId(), reorderQuantity);
                
                // Send notification via RabbitMQ
                rabbitTemplate.convertAndSend("inventory.restock", 
                    new RestockRequest(item.getProductId(), reorderQuantity));
            }
        }
    }
    
    private int calculateOptimalReorderQuantity(Inventory item) {
        // Business logic: EOQ formula or demand forecasting
        int averageDailySales = getAverageDailySales(item.getProductId());
        int leadTimeDays = getSupplierLeadTime(item.getProductId());
        int safetyStock = averageDailySales * 7; // 1 week safety
        
        return (averageDailySales * leadTimeDays) + safetyStock;
    }
}
```

### **2. Dynamic Pricing Based on Stock Levels:**
```java
@Service
public class DynamicPricingService {
    
    public BigDecimal calculateOptimalPrice(Long productId) {
        Inventory inventory = inventoryService.getInventoryByProduct(productId);
        Product product = productService.getProduct(productId);
        
        // Business logic: Price adjustment based on stock
        BigDecimal basePrice = product.getBasePrice();
        
        if (inventory.isLowStock()) {
            // Increase price by 10% for low stock
            return basePrice.multiply(BigDecimal.valueOf(1.10));
        } else if (inventory.getAvailableQuantity() > inventory.getMaximumStockLevel() * 0.8) {
            // Decrease price by 5% for excess stock
            return basePrice.multiply(BigDecimal.valueOf(0.95));
        }
        
        return basePrice;
    }
}
```

## 🚚 **Shipping Service Business Logic Examples:**

### **1. Smart Carrier Selection:**
```java
@Service
public class CarrierOptimizationService {
    
    public CarrierRecommendation selectOptimalCarrier(ShipmentRequest request) {
        List<CarrierQuote> quotes = getAllCarrierQuotes(request);
        
        // Business logic: Multi-criteria decision
        return quotes.stream()
            .map(quote -> {
                double score = calculateCarrierScore(quote, request);
                return new CarrierRecommendation(quote.getCarrier(), score, quote.getCost());
            })
            .max(Comparator.comparing(CarrierRecommendation::getScore))
            .orElse(getDefaultCarrier());
    }
    
    private double calculateCarrierScore(CarrierQuote quote, ShipmentRequest request) {
        double costScore = 1.0 / quote.getCost().doubleValue(); // Lower cost = higher score
        double speedScore = 1.0 / quote.getDeliveryDays(); // Faster = higher score
        double reliabilityScore = getCarrierReliabilityRating(quote.getCarrier());
        
        // Business weights
        return (costScore * 0.4) + (speedScore * 0.4) + (reliabilityScore * 0.2);
    }
}
```

### **2. Delivery Route Optimization:**
```java
@Service
public class RouteOptimizationService {
    
    public OptimizedRoute planDeliveryRoute(List<Shipment> shipments) {
        // Business logic: Traveling salesman problem solver
        List<Address> addresses = shipments.stream()
            .map(Shipment::getRecipientAddress)
            .collect(Collectors.toList());
        
        // Use algorithms like nearest neighbor or genetic algorithm
        List<Address> optimizedRoute = solveRoutingProblem(addresses);
        
        return new OptimizedRoute(optimizedRoute, calculateTotalDistance(optimizedRoute));
    }
}
```

## 🔄 **Inter-Service Business Logic:**

### **Order Processing Workflow:**
```java
@Service
public class OrderProcessingWorkflow {
    
    @EventListener
    public void handleOrderCreated(OrderCreatedEvent event) {
        // 1. Check inventory
        boolean stockAvailable = inventoryService.reserveStock(
            event.getProductId(), event.getQuantity());
        
        if (stockAvailable) {
            // 2. Process payment
            PaymentResult paymentResult = paymentService.processPayment(event.getPaymentInfo());
            
            if (paymentResult.isSuccessful()) {
                // 3. Confirm inventory
                inventoryService.confirmSale(event.getProductId(), event.getQuantity());
                
                // 4. Create shipment
                Shipment shipment = shippingService.createShipment(
                    ShipmentRequest.fromOrder(event.getOrder()));
                
                // 5. Send confirmation
                notificationService.sendOrderConfirmation(event.getCustomerId(), shipment);
            } else {
                // Release reserved stock
                inventoryService.releaseReservedStock(event.getProductId(), event.getQuantity());
            }
        }
    }
}
```

## 📊 **Business Analytics & Insights:**

### **Real-time Business Metrics:**
```java
@RestController
@RequestMapping("/api/analytics")
public class BusinessAnalyticsController {
    
    @GetMapping("/inventory-health")
    public InventoryHealthReport getInventoryHealth() {
        return InventoryHealthReport.builder()
            .totalProducts(inventoryService.getTotalProductCount())
            .lowStockCount(inventoryService.getLowStockItems().size())
            .outOfStockCount(inventoryService.getOutOfStockItems().size())
            .totalValue(inventoryService.getTotalInventoryValue())
            .turnoverRate(calculateTurnoverRate())
            .build();
    }
    
    @GetMapping("/shipping-performance")
    public ShippingPerformanceReport getShippingPerformance() {
        return ShippingPerformanceReport.builder()
            .averageDeliveryTime(shippingService.getAverageDeliveryTime())
            .onTimeDeliveryRate(shippingService.getOnTimeDeliveryRate())
            .totalShipments(shippingService.getTotalShipmentsCount())
            .carrierPerformance(shippingService.getCarrierPerformanceMetrics())
            .build();
    }
}
```

## 🎛️ **Message-Driven Business Logic (RabbitMQ):**

### **Event-Driven Inventory Updates:**
```java
@RabbitListener(queues = "order.completed")
public void handleOrderCompleted(OrderCompletedEvent event) {
    // Business logic: Update inventory after successful order
    inventoryService.confirmSale(event.getProductId(), event.getQuantity());
    
    // Business logic: Check if restocking needed
    if (inventoryService.isRestockingNeeded(event.getProductId())) {
        publisher.publish("inventory.restock.needed", 
            new RestockNeededEvent(event.getProductId()));
    }
}

@RabbitListener(queues = "shipping.delivered")
public void handleDeliveryCompleted(DeliveryCompletedEvent event) {
    // Business logic: Update customer satisfaction metrics
    customerService.updateDeliveryExperience(event.getCustomerId(), event.getDeliveryRating());
    
    // Business logic: Trigger follow-up actions
    if (event.getDeliveryRating() >= 4) {
        marketingService.triggerLoyaltyReward(event.getCustomerId());
    }
}
```

## 🚀 **Running on 8GB RAM:**

### **Memory-Optimized Startup:**
```powershell
# Start infrastructure first (use ~1.5GB)
docker-compose -f docker-compose-light.yml up -d postgres-shared redis rabbitmq eureka-server

# Wait for infrastructure to stabilize
Start-Sleep -Seconds 30

# Start core services (use ~1.5GB more)
docker-compose -f docker-compose-light.yml up -d inventory-service shipping-service

# Total usage: ~3GB (perfect for 8GB system!)
```

## 🎯 **Business Logic Benefits:**

1. **Automated Decision Making** ✅
2. **Real-time Optimization** ✅  
3. **Event-driven Workflows** ✅
4. **Performance Analytics** ✅
5. **Smart Resource Management** ✅

Your microservices can handle **complex business scenarios** with:
- **Inventory optimization algorithms**
- **Dynamic pricing strategies**
- **Smart shipping decisions**  
- **Automated workflows**
- **Real-time analytics**

**Yes, this runs perfectly on 8GB RAM with Docker Desktop!** 🚀