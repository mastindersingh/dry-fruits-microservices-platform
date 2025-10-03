# 🎯 User Access Matrix - Who Uses What?

## 🛒 **Customer Portal** (Port 3000) - **PUBLIC ACCESS**

### **Target Users: End Customers**

| User Type | Use Cases | Key Features |
|-----------|-----------|--------------|
| **🏠 Retail Customers** | • Browse and buy dry fruits<br>• Track personal orders<br>• Manage shopping cart | • Product catalog<br>• Shopping cart<br>• Order history<br>• Shipment tracking |
| **🏢 Small Business Owners** | • Bulk purchases for cafes/restaurants<br>• Recurring orders<br>• Volume pricing | • Quantity management<br>• Reorder functionality<br>• Order summaries |
| **🎁 Gift Buyers** | • Purchase for special occasions<br>• Send to different addresses<br>• Custom packaging | • Product browsing<br>• Checkout process<br>• Delivery options |

### **What They See:**
- ✅ Product listings with prices
- ✅ Stock availability 
- ✅ Shopping cart and checkout
- ✅ Order history and tracking
- ✅ Search and filter products
- ❌ No inventory management
- ❌ No system administration
- ❌ No business analytics

---

## 🛠️ **Admin Dashboard** (Port 3001) - **INTERNAL ACCESS ONLY**

### **Target Users: Internal Teams**

| Department | Role | Responsibilities | Dashboard Access |
|------------|------|-----------------|------------------|
| **📦 Operations** | **Inventory Manager** | • Monitor stock levels<br>• Add new products<br>• Set pricing<br>• Handle suppliers | • Inventory Management<br>• Product Addition<br>• Stock Adjustments<br>• Low Stock Alerts |
| **📦 Operations** | **Warehouse Staff** | • Fulfill orders<br>• Update stock after receiving<br>• Handle returns | • Inventory View<br>• Order Details<br>• Stock Updates |
| **🚚 Logistics** | **Shipping Coordinator** | • Create shipments<br>• Update tracking info<br>• Handle carrier relations<br>• Manage delays | • Shipping Management<br>• Tracking Updates<br>• Carrier Dashboard<br>• Delivery Reports |
| **🛒 Customer Service** | **Order Support** | • Help customers with orders<br>• Process refunds<br>• Handle complaints<br>• Update order status | • Order Management<br>• Customer Lookup<br>• Status Updates<br>• Order History |
| **💼 Management** | **Business Analyst** | • Monitor sales performance<br>• Analyze trends<br>• Generate reports<br>• Track KPIs | • Analytics Dashboard<br>• Sales Reports<br>• Performance Metrics<br>• Customer Insights |
| **💼 Management** | **Operations Manager** | • Oversee daily operations<br>• Monitor team performance<br>• Make strategic decisions | • Full Dashboard Access<br>• All Reports<br>• Team Performance<br>• Business Metrics |
| **👨‍💻 IT Department** | **System Administrator** | • Monitor system health<br>• Troubleshoot issues<br>• Manage deployments<br>• Ensure uptime | • System Health<br>• Service Monitoring<br>• Log Analysis<br>• Performance Metrics |
| **👨‍💻 IT Department** | **DevOps Engineer** | • Deploy applications<br>• Monitor infrastructure<br>• Handle scaling<br>• Maintain services | • System Status<br>• Service Health<br>• Infrastructure Metrics<br>• Alert Management |

### **What Internal Teams See:**
- ✅ Complete inventory management
- ✅ All customer orders and details  
- ✅ Shipping and logistics tracking
- ✅ System health and monitoring
- ✅ Business analytics and reports
- ✅ User management capabilities
- ✅ Administrative controls

---

## 🔐 **Access Control Summary**

### **Public Access (Customer Portal):**
```
🌐 http://localhost:3000
👥 Anyone can access
🛒 Shopping and order tracking only
📱 Mobile-friendly interface
🔒 No administrative functions
```

### **Internal Access (Admin Dashboard):**
```
🛠️ http://localhost:3001  
👨‍💼 Internal team members only
🔐 Full system management
📊 Business intelligence tools
🖥️ Desktop-optimized interface
⚙️ All administrative functions
```

---

## 🎯 **Real-World Usage Scenarios**

### **Scenario 1: Customer Order Workflow**
1. **Customer (Sarah)** → Uses **Customer Portal** (3000)
   - Browses almonds, adds to cart, places order
   
2. **Order Support (Tom)** → Uses **Admin Dashboard** (3001)
   - Sees new order, updates status to "Processing"
   
3. **Inventory Manager (Lisa)** → Uses **Admin Dashboard** (3001)
   - Reserves stock, updates inventory levels
   
4. **Shipping Coordinator (Mike)** → Uses **Admin Dashboard** (3001)
   - Creates shipment, assigns tracking number
   
5. **Customer (Sarah)** → Uses **Customer Portal** (3000)
   - Tracks order progress, receives delivery

### **Scenario 2: Inventory Management**
1. **System** → **Admin Dashboard** alerts
   - Low stock warning for "Premium Walnuts"
   
2. **Inventory Manager (Lisa)** → Uses **Admin Dashboard** (3001)
   - Reviews stock levels, places supplier order
   
3. **Warehouse Staff (John)** → Uses **Admin Dashboard** (3001)
   - Receives shipment, updates stock quantities
   
4. **Customers** → **Customer Portal** (3000)
   - See updated stock availability

### **Scenario 3: System Monitoring**
1. **System Admin (Alex)** → Uses **Admin Dashboard** (3001)
   - Monitors service health, checks system logs
   
2. **Issue Detected** → Service goes offline
   - Admin receives alerts, troubleshoots issue
   
3. **Resolution** → Service restored
   - Customers continue shopping without interruption

---

## 📋 **Feature Access Matrix**

| Feature | Customer Portal | Admin Dashboard |
|---------|----------------|-----------------|
| **Product Browsing** | ✅ View only | ✅ Full management |
| **Inventory Levels** | ✅ View availability | ✅ Full stock control |
| **Order Placement** | ✅ Create orders | ✅ View/manage all orders |
| **Order Tracking** | ✅ Own orders only | ✅ All customer orders |
| **Shipping Info** | ✅ Track own shipments | ✅ Manage all shipments |
| **User Accounts** | ✅ Own account | ✅ All customer accounts |
| **Analytics** | ❌ No access | ✅ Full business intelligence |
| **System Health** | ❌ No access | ✅ Complete monitoring |
| **Configuration** | ❌ No access | ✅ Full system control |

---

## 🚀 **Getting Started**

### **For Customers:**
1. Visit: http://localhost:3000
2. Browse products and add to cart
3. Complete checkout process
4. Track your orders

### **For Internal Teams:**
1. Visit: http://localhost:3001
2. Use appropriate sections based on your role
3. Monitor dashboards and KPIs
4. Manage operations efficiently

Both interfaces work together to provide a **complete e-commerce solution** with clear separation between customer-facing and internal management functions! 🎉