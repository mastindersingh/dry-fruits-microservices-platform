# 🚀 Dry Fruits Microservices - Frontend Access Guide

## 📋 Service Status & Access URLs

### **Core Infrastructure Services**
- **🔧 Eureka Server (Service Discovery)**: http://localhost:8761
- **🐰 RabbitMQ Management**: http://localhost:15672 (username: `guest`, password: `guest`)
- **📊 PostgreSQL Database**: localhost:5432 (username: `postgres`, password: `password`)
- **⚡ Redis Cache**: localhost:6379

### **Business Services APIs**
- **📦 Inventory Service**: http://localhost:8084
  - Swagger UI: http://localhost:8084/swagger-ui.html
  - API Docs: http://localhost:8084/v3/api-docs
  - Health Check: http://localhost:8084/actuator/health

- **🚚 Shipping Service**: http://localhost:8085
  - Swagger UI: http://localhost:8085/swagger-ui.html
  - API Docs: http://localhost:8085/v3/api-docs
  - Health Check: http://localhost:8085/actuator/health

## 🌐 How to Access Services from Frontend

### **Option 1: Direct API Calls (Recommended for Testing)**

#### **Inventory Service Examples:**

```javascript
// Get all inventory items
fetch('http://localhost:8084/inventory/v1/items')
  .then(response => response.json())
  .then(data => console.log(data));

// Add new inventory item
fetch('http://localhost:8084/inventory/v1/items', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    productId: "ALMOND001",
    productName: "Premium Almonds",
    warehouseId: "WH001",
    quantity: 100,
    unitPrice: 25.99,
    category: "NUTS"
  })
})
.then(response => response.json())
.then(data => console.log('Success:', data));

// Check inventory for specific product
fetch('http://localhost:8084/inventory/v1/items/product/ALMOND001')
  .then(response => response.json())
  .then(data => console.log(data));
```

#### **Shipping Service Examples:**

```javascript
// Create a new shipment
fetch('http://localhost:8085/shipping/v1/shipments', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    orderId: "ORDER001",
    customerId: "CUST001",
    shippingAddress: {
      street: "123 Main St",
      city: "New York",
      state: "NY",
      zipCode: "10001",
      country: "USA"
    },
    items: [
      {
        productId: "ALMOND001",
        productName: "Premium Almonds",
        quantity: 2,
        weight: 1.5
      }
    ],
    totalWeight: 1.5,
    totalValue: 51.98
  })
})
.then(response => response.json())
.then(data => console.log('Shipment created:', data));

// Track shipment
fetch('http://localhost:8085/shipping/v1/shipments/SHIP001/track')
  .then(response => response.json())
  .then(data => console.log('Tracking info:', data));
```

### **Option 2: React/Vue/Angular Frontend Integration**

#### **React Example Component:**

```jsx
import React, { useState, useEffect } from 'react';

const InventoryManager = () => {
  const [inventory, setInventory] = useState([]);
  const [newItem, setNewItem] = useState({
    productId: '',
    productName: '',
    warehouseId: 'WH001',
    quantity: 0,
    unitPrice: 0,
    category: 'NUTS'
  });

  useEffect(() => {
    fetchInventory();
  }, []);

  const fetchInventory = async () => {
    try {
      const response = await fetch('http://localhost:8084/inventory/v1/items');
      const data = await response.json();
      setInventory(data);
    } catch (error) {
      console.error('Error fetching inventory:', error);
    }
  };

  const addItem = async (e) => {
    e.preventDefault();
    try {
      const response = await fetch('http://localhost:8084/inventory/v1/items', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(newItem)
      });
      
      if (response.ok) {
        fetchInventory(); // Refresh the list
        setNewItem({
          productId: '',
          productName: '',
          warehouseId: 'WH001',
          quantity: 0,
          unitPrice: 0,
          category: 'NUTS'
        });
      }
    } catch (error) {
      console.error('Error adding item:', error);
    }
  };

  return (
    <div>
      <h2>Dry Fruits Inventory</h2>
      
      {/* Add Item Form */}
      <form onSubmit={addItem}>
        <input
          type="text"
          placeholder="Product ID"
          value={newItem.productId}
          onChange={(e) => setNewItem({...newItem, productId: e.target.value})}
          required
        />
        <input
          type="text"
          placeholder="Product Name"
          value={newItem.productName}
          onChange={(e) => setNewItem({...newItem, productName: e.target.value})}
          required
        />
        <input
          type="number"
          placeholder="Quantity"
          value={newItem.quantity}
          onChange={(e) => setNewItem({...newItem, quantity: parseInt(e.target.value)})}
          required
        />
        <input
          type="number"
          step="0.01"
          placeholder="Unit Price"
          value={newItem.unitPrice}
          onChange={(e) => setNewItem({...newItem, unitPrice: parseFloat(e.target.value)})}
          required
        />
        <button type="submit">Add Item</button>
      </form>

      {/* Inventory List */}
      <div>
        <h3>Current Inventory</h3>
        {inventory.map(item => (
          <div key={item.id} style={{border: '1px solid #ccc', margin: '10px', padding: '10px'}}>
            <h4>{item.productName} ({item.productId})</h4>
            <p>Quantity: {item.quantity}</p>
            <p>Price: ${item.unitPrice}</p>
            <p>Warehouse: {item.warehouseId}</p>
            <p>Category: {item.category}</p>
          </div>
        ))}
      </div>
    </div>
  );
};

export default InventoryManager;
```

### **Option 3: Email Integration Example**

```javascript
// Email notification when inventory is low
const checkLowInventoryAndNotify = async () => {
  try {
    const response = await fetch('http://localhost:8084/inventory/v1/items/low-stock?threshold=10');
    const lowStockItems = await response.json();
    
    if (lowStockItems.length > 0) {
      // Send email notification
      const emailData = {
        to: 'admin@dryfruits.com',
        subject: 'Low Inventory Alert',
        body: `The following items are running low:
        ${lowStockItems.map(item => 
          `- ${item.productName}: ${item.quantity} remaining`
        ).join('\n')}`
      };
      
      // Assuming you have an email service
      await fetch('http://localhost:3001/send-email', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(emailData)
      });
    }
  } catch (error) {
    console.error('Error checking inventory:', error);
  }
};

// Email notification when shipment status changes
const trackShipmentWithNotification = async (shipmentId, customerEmail) => {
  try {
    const response = await fetch(`http://localhost:8085/shipping/v1/shipments/${shipmentId}/track`);
    const trackingInfo = await response.json();
    
    // Send status update email
    const emailData = {
      to: customerEmail,
      subject: `Shipment Update - ${shipmentId}`,
      body: `Your shipment status has been updated:
      
      Status: ${trackingInfo.status}
      Location: ${trackingInfo.currentLocation}
      Estimated Delivery: ${trackingInfo.estimatedDelivery}
      
      Track your package: http://localhost:8085/shipping/v1/shipments/${shipmentId}/track`
    };
    
    await fetch('http://localhost:3001/send-email', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(emailData)
    });
  } catch (error) {
    console.error('Error tracking shipment:', error);
  }
};
```

## 🔧 Service Management Commands

### **Check Service Status:**
```bash
docker ps
```

### **View Service Logs:**
```bash
docker logs inventory-service
docker logs shipping-service
docker logs eureka-server
```

### **Restart Services:**
```bash
docker-compose -f docker-compose-light.yml restart
```

### **Stop All Services:**
```bash
docker-compose -f docker-compose-light.yml down
```

### **Start Services:**
```bash
docker-compose -f docker-compose-light.yml up -d
```

## 📊 Database Access

### **Connect to PostgreSQL:**
```bash
# Using psql command line
psql -h localhost -p 5432 -U postgres -d inventory_db

# Or connect to shipping database
psql -h localhost -p 5432 -U postgres -d shipping_db
```

### **Sample Database Queries:**
```sql
-- Check inventory items
SELECT * FROM inventory_items;

-- Check shipments
SELECT * FROM shipments;

-- Check addresses
SELECT * FROM addresses;
```

## 🎯 Complete E-commerce Integration Example

```javascript
class DryFruitsEcommerceAPI {
  constructor() {
    this.inventoryAPI = 'http://localhost:8084/inventory/v1';
    this.shippingAPI = 'http://localhost:8085/shipping/v1';
  }

  // Complete order processing workflow
  async processOrder(orderData) {
    try {
      // 1. Check inventory availability
      const inventoryCheck = await this.checkInventoryAvailability(orderData.items);
      if (!inventoryCheck.available) {
        throw new Error(`Insufficient inventory: ${inventoryCheck.missingItems.join(', ')}`);
      }

      // 2. Reserve inventory
      await this.reserveInventory(orderData.items);

      // 3. Create shipment
      const shipment = await this.createShipment(orderData);

      // 4. Send confirmation email
      await this.sendOrderConfirmationEmail(orderData, shipment);

      return {
        success: true,
        orderId: orderData.orderId,
        shipmentId: shipment.shipmentId,
        message: 'Order processed successfully'
      };
    } catch (error) {
      console.error('Order processing failed:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async checkInventoryAvailability(items) {
    const results = await Promise.all(
      items.map(async item => {
        const response = await fetch(`${this.inventoryAPI}/items/product/${item.productId}`);
        const inventory = await response.json();
        return {
          productId: item.productId,
          requested: item.quantity,
          available: inventory.quantity,
          sufficient: inventory.quantity >= item.quantity
        };
      })
    );

    const missingItems = results
      .filter(r => !r.sufficient)
      .map(r => `${r.productId} (need ${r.requested}, have ${r.available})`);

    return {
      available: missingItems.length === 0,
      missingItems
    };
  }

  async reserveInventory(items) {
    for (const item of items) {
      await fetch(`${this.inventoryAPI}/items/product/${item.productId}/reserve`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ quantity: item.quantity })
      });
    }
  }

  async createShipment(orderData) {
    const response = await fetch(`${this.shippingAPI}/shipments`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        orderId: orderData.orderId,
        customerId: orderData.customerId,
        shippingAddress: orderData.shippingAddress,
        items: orderData.items,
        totalWeight: orderData.totalWeight,
        totalValue: orderData.totalValue
      })
    });

    return await response.json();
  }

  async sendOrderConfirmationEmail(orderData, shipment) {
    const emailData = {
      to: orderData.customerEmail,
      subject: `Order Confirmation - ${orderData.orderId}`,
      body: `
        Dear Customer,
        
        Your order has been confirmed and is being processed.
        
        Order ID: ${orderData.orderId}
        Shipment ID: ${shipment.shipmentId}
        
        Items:
        ${orderData.items.map(item => 
          `- ${item.productName} x${item.quantity}`
        ).join('\n')}
        
        Shipping Address:
        ${orderData.shippingAddress.street}
        ${orderData.shippingAddress.city}, ${orderData.shippingAddress.state} ${orderData.shippingAddress.zipCode}
        
        Track your shipment: http://localhost:8085/shipping/v1/shipments/${shipment.shipmentId}/track
        
        Thank you for your business!
      `
    };

    // Send email (implement your email service)
    console.log('Email sent:', emailData);
  }
}

// Usage example
const ecommerceAPI = new DryFruitsEcommerceAPI();

const sampleOrder = {
  orderId: 'ORDER001',
  customerId: 'CUST001',
  customerEmail: 'customer@example.com',
  shippingAddress: {
    street: '123 Main St',
    city: 'New York',
    state: 'NY',
    zipCode: '10001',
    country: 'USA'
  },
  items: [
    {
      productId: 'ALMOND001',
      productName: 'Premium Almonds',
      quantity: 2,
      weight: 1.5
    }
  ],
  totalWeight: 1.5,
  totalValue: 51.98
};

ecommerceAPI.processOrder(sampleOrder)
  .then(result => console.log('Order result:', result));
```

## 🚨 Important Notes

1. **CORS**: If you're calling from a web frontend, you may need to configure CORS in your services
2. **Authentication**: These examples don't include authentication - add JWT tokens in production
3. **Error Handling**: Always implement proper error handling in your frontend
4. **Environment**: Use environment variables for API URLs in production
5. **Database**: The services share a PostgreSQL instance but use separate databases for data isolation

Your microservices are now fully operational and ready for frontend integration! 🎉