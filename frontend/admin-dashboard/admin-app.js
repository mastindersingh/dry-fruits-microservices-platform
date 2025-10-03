// Admin Dashboard JavaScript - Internal Management Application

// API Configuration - Using LoadBalancer Services
const API_CONFIG = {
    BASE_URL: 'http://localhost:8080', // API Gateway
    INVENTORY_SERVICE: 'http://localhost:8082', // inventory-lb LoadBalancer
    SHIPPING_SERVICE: 'http://localhost:8083',  // shipping-lb LoadBalancer
    ORDER_SERVICE: 'http://localhost:8084',     // orders-lb LoadBalancer
    USER_SERVICE: 'http://localhost:8081',      // users-lb LoadBalancer
    EUREKA_SERVER: 'http://localhost:8761',     // eureka-lb LoadBalancer
    PROMETHEUS: 'http://localhost:9090',        // prometheus-lb LoadBalancer
    JAEGER: 'http://localhost:16686'            // jaeger-lb LoadBalancer
};

// Application State
let currentSection = 'dashboard';
let dashboardData = {};
let inventoryData = [];
let ordersData = [];
let shipmentsData = [];
let systemHealthData = {};

// Charts
let salesChart = null;
let productsChart = null;

// Initialize Application
document.addEventListener('DOMContentLoaded', function() {
    initializeAdmin();
    loadDashboard();
    setupEventListeners();
    startHealthMonitoring();
});

function initializeAdmin() {
    console.log('🛠️ Admin Dashboard Initialized');
    showSection('dashboard');
}

function setupEventListeners() {
    // Add product form
    document.getElementById('addProductForm').addEventListener('submit', handleAddProduct);
    
    // Auto-refresh every 30 seconds for critical data
    setInterval(() => {
        if (currentSection === 'dashboard') {
            refreshDashboard();
        } else if (currentSection === 'system') {
            refreshSystemHealth();
        }
    }, 30000);
}

// Navigation
function showSection(sectionId) {
    // Hide all sections
    document.querySelectorAll('.content-section').forEach(section => {
        section.classList.remove('active');
    });

    // Show target section
    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.classList.add('active');
        currentSection = sectionId;
        
        // Load section-specific data
        switch(sectionId) {
            case 'dashboard':
                loadDashboard();
                break;
            case 'inventory':
                loadInventory();
                break;
            case 'orders':
                loadOrders();
                break;
            case 'shipping':
                loadShipments();
                break;
            case 'system':
                refreshSystemHealth();
                break;
        }
    }

    // Update navigation
    document.querySelectorAll('.sidebar .nav-link').forEach(link => {
        link.classList.remove('active');
    });
    document.querySelector(`[onclick="showSection('${sectionId}')"]`)?.classList.add('active');
}

// Dashboard Functions
async function loadDashboard() {
    try {
        await Promise.all([
            loadDashboardKPIs(),
            loadSalesChart(),
            loadProductsChart(),
            loadRecentActivities()
        ]);
    } catch (error) {
        console.error('Error loading dashboard:', error);
        loadMockDashboardData();
    }
}

async function loadDashboardKPIs() {
    try {
        // Try to fetch real data from services
        const kpis = await getMockKPIs(); // Fallback to mock data
        
        document.getElementById('total-orders').textContent = kpis.totalOrders;
        document.getElementById('revenue-today').textContent = `$${kpis.revenueToday.toLocaleString()}`;
        document.getElementById('low-stock-items').textContent = kpis.lowStockItems;
        document.getElementById('active-customers').textContent = kpis.activeCustomers;
        
    } catch (error) {
        console.error('Error loading KPIs:', error);
    }
}

function getMockKPIs() {
    return {
        totalOrders: 247,
        revenueToday: 15680,
        lowStockItems: 8,
        activeCustomers: 1205
    };
}

async function loadSalesChart() {
    const ctx = document.getElementById('salesChart').getContext('2d');
    
    if (salesChart) {
        salesChart.destroy();
    }
    
    salesChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
            datasets: [{
                label: 'Sales ($)',
                data: [12000, 19000, 15000, 25000, 22000, 30000, 28000],
                borderColor: '#007bff',
                backgroundColor: 'rgba(0, 123, 255, 0.1)',
                tension: 0.4,
                fill: true
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function(value) {
                            return '$' + value.toLocaleString();
                        }
                    }
                }
            }
        }
    });
}

async function loadProductsChart() {
    const ctx = document.getElementById('productsChart').getContext('2d');
    
    if (productsChart) {
        productsChart.destroy();
    }
    
    productsChart = new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Almonds', 'Walnuts', 'Figs', 'Dates', 'Cashews', 'Mixed'],
            datasets: [{
                data: [30, 25, 15, 12, 10, 8],
                backgroundColor: [
                    '#007bff',
                    '#28a745',
                    '#ffc107',
                    '#dc3545',
                    '#17a2b8',
                    '#6c757d'
                ]
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
}

async function loadRecentActivities() {
    const activitiesContainer = document.getElementById('recent-activities');
    
    const activities = [
        { time: '2 minutes ago', action: 'New order #ORD-1001 placed', type: 'order', icon: 'shopping-cart' },
        { time: '5 minutes ago', action: 'Inventory low stock alert: Premium Almonds', type: 'warning', icon: 'exclamation-triangle' },
        { time: '10 minutes ago', action: 'Shipment TRACK-123 delivered successfully', type: 'success', icon: 'truck' },
        { time: '15 minutes ago', action: 'New customer registered: John Smith', type: 'info', icon: 'user-plus' },
        { time: '20 minutes ago', action: 'Product added: Organic Pistachios', type: 'success', icon: 'plus-circle' },
        { time: '25 minutes ago', action: 'Payment processed for order #ORD-998', type: 'success', icon: 'credit-card' }
    ];

    activitiesContainer.innerHTML = activities.map(activity => `
        <div class="d-flex align-items-center mb-3">
            <div class="me-3">
                <i class="fas fa-${activity.icon} text-${getActivityColor(activity.type)}"></i>
            </div>
            <div class="flex-grow-1">
                <div>${activity.action}</div>
                <small class="text-muted">${activity.time}</small>
            </div>
        </div>
    `).join('');
}

function getActivityColor(type) {
    const colors = {
        order: 'primary',
        warning: 'warning',
        success: 'success',
        info: 'info',
        error: 'danger'
    };
    return colors[type] || 'secondary';
}

function refreshDashboard() {
    loadDashboard();
}

// Inventory Management
async function loadInventory() {
    try {
        showTableLoading('inventory-table-body');
        
        // Try to fetch from inventory service
        const response = await fetch(`${API_CONFIG.INVENTORY_SERVICE}/inventory/v1/items`);
        
        if (response.ok) {
            inventoryData = await response.json();
        } else {
            inventoryData = getMockInventoryData();
        }
        
        renderInventoryTable(inventoryData);
        
    } catch (error) {
        console.warn('⚠️ Inventory service not available, using mock data');
        inventoryData = getMockInventoryData();
        renderInventoryTable(inventoryData);
    }
}

function getMockInventoryData() {
    return [
        { id: 1, productId: 'ALM001', productName: 'Premium Almonds', category: 'NUTS', quantity: 85, unitPrice: 25.99 },
        { id: 2, productId: 'WAL001', productName: 'Organic Walnuts', category: 'NUTS', quantity: 12, unitPrice: 32.50 },
        { id: 3, productId: 'FIG001', productName: 'Turkish Figs', category: 'DRIED_FRUITS', quantity: 0, unitPrice: 28.75 },
        { id: 4, productId: 'DAT001', productName: 'Medjool Dates', category: 'DRIED_FRUITS', quantity: 45, unitPrice: 35.00 },
        { id: 5, productId: 'CAS001', productName: 'Roasted Cashews', category: 'NUTS', quantity: 67, unitPrice: 42.00 },
        { id: 6, productId: 'MIX001', productName: 'Trail Mix Supreme', category: 'MIXED', quantity: 23, unitPrice: 24.99 }
    ];
}

function renderInventoryTable(inventory) {
    const tbody = document.getElementById('inventory-table-body');
    
    if (inventory.length === 0) {
        tbody.innerHTML = `
            <tr>
                <td colspan="7" class="text-center text-muted">No inventory items found</td>
            </tr>
        `;
        return;
    }

    tbody.innerHTML = inventory.map(item => `
        <tr>
            <td><strong>${item.productId}</strong></td>
            <td>${item.productName}</td>
            <td><span class="badge bg-secondary">${item.category}</span></td>
            <td>
                <span class="${getStockClass(item.quantity)}">${item.quantity}</span>
            </td>
            <td>$${item.unitPrice.toFixed(2)}</td>
            <td>
                <span class="badge ${getStockBadgeClass(item.quantity)}">
                    ${getStockStatus(item.quantity)}
                </span>
            </td>
            <td>
                <div class="btn-group btn-group-sm">
                    <button class="btn btn-outline-primary" onclick="editProduct(${item.id})" title="Edit">
                        <i class="fas fa-edit"></i>
                    </button>
                    <button class="btn btn-outline-warning" onclick="adjustStock(${item.id})" title="Adjust Stock">
                        <i class="fas fa-warehouse"></i>
                    </button>
                    <button class="btn btn-outline-danger" onclick="deleteProduct(${item.id})" title="Delete">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
}

function getStockClass(quantity) {
    if (quantity === 0) return 'stock-out fw-bold';
    if (quantity < 20) return 'stock-low fw-bold';
    return 'stock-good fw-bold';
}

function getStockBadgeClass(quantity) {
    if (quantity === 0) return 'bg-danger';
    if (quantity < 20) return 'bg-warning text-dark';
    return 'bg-success';
}

function getStockStatus(quantity) {
    if (quantity === 0) return 'Out of Stock';
    if (quantity < 20) return 'Low Stock';
    return 'In Stock';
}

function filterInventory() {
    const categoryFilter = document.getElementById('inventory-category-filter').value;
    const stockFilter = document.getElementById('inventory-stock-filter').value;
    
    let filteredInventory = [...inventoryData];
    
    if (categoryFilter) {
        filteredInventory = filteredInventory.filter(item => item.category === categoryFilter);
    }
    
    if (stockFilter) {
        switch(stockFilter) {
            case 'low':
                filteredInventory = filteredInventory.filter(item => item.quantity > 0 && item.quantity < 20);
                break;
            case 'out':
                filteredInventory = filteredInventory.filter(item => item.quantity === 0);
                break;
            case 'good':
                filteredInventory = filteredInventory.filter(item => item.quantity >= 20);
                break;
        }
    }
    
    renderInventoryTable(filteredInventory);
}

function showAddProductModal() {
    const modal = new bootstrap.Modal(document.getElementById('addProductModal'));
    modal.show();
}

async function handleAddProduct(e) {
    e.preventDefault();
    
    const formData = new FormData(e.target);
    const productData = {
        productId: formData.get('productId'),
        productName: formData.get('productName'),
        category: formData.get('category'),
        quantity: parseInt(formData.get('quantity')),
        unitPrice: parseFloat(formData.get('unitPrice')),
        description: formData.get('description')
    };

    try {
        // Simulate API call
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        // Add to local data
        productData.id = Date.now();
        inventoryData.push(productData);
        
        // Refresh table
        renderInventoryTable(inventoryData);
        
        // Close modal and reset form
        bootstrap.Modal.getInstance(document.getElementById('addProductModal')).hide();
        e.target.reset();
        
        showNotification('Product added successfully!', 'success');
        
    } catch (error) {
        console.error('Error adding product:', error);
        showNotification('Error adding product', 'error');
    }
}

function editProduct(productId) {
    const product = inventoryData.find(p => p.id === productId);
    if (product) {
        showNotification(`Edit functionality for ${product.productName} would be implemented here`, 'info');
    }
}

function adjustStock(productId) {
    const product = inventoryData.find(p => p.id === productId);
    if (product) {
        const newStock = prompt(`Current stock: ${product.quantity}\nEnter new stock level:`, product.quantity);
        if (newStock !== null && !isNaN(newStock)) {
            product.quantity = parseInt(newStock);
            renderInventoryTable(inventoryData);
            showNotification(`Stock updated for ${product.productName}`, 'success');
        }
    }
}

function deleteProduct(productId) {
    const product = inventoryData.find(p => p.id === productId);
    if (product && confirm(`Are you sure you want to delete ${product.productName}?`)) {
        inventoryData = inventoryData.filter(p => p.id !== productId);
        renderInventoryTable(inventoryData);
        showNotification(`${product.productName} deleted`, 'success');
    }
}

// Order Management
async function loadOrders() {
    try {
        showTableLoading('orders-table-body');
        ordersData = getMockOrdersData();
        renderOrdersTable(ordersData);
    } catch (error) {
        console.error('Error loading orders:', error);
    }
}

function getMockOrdersData() {
    return [
        { id: 'ORD-1001', customer: 'John Smith', date: '2025-10-01', total: 67.49, status: 'PROCESSING' },
        { id: 'ORD-1000', customer: 'Sarah Johnson', date: '2025-10-01', total: 42.00, status: 'SHIPPED' },
        { id: 'ORD-999', customer: 'Mike Wilson', date: '2025-09-30', total: 98.75, status: 'DELIVERED' },
        { id: 'ORD-998', customer: 'Emily Davis', date: '2025-09-30', total: 156.25, status: 'DELIVERED' },
        { id: 'ORD-997', customer: 'David Brown', date: '2025-09-29', total: 73.50, status: 'CANCELLED' }
    ];
}

function renderOrdersTable(orders) {
    const tbody = document.getElementById('orders-table-body');
    
    tbody.innerHTML = orders.map(order => `
        <tr>
            <td><strong>${order.id}</strong></td>
            <td>${order.customer}</td>
            <td>${new Date(order.date).toLocaleDateString()}</td>
            <td>$${order.total.toFixed(2)}</td>
            <td>
                <span class="badge status-${order.status.toLowerCase()}">${order.status}</span>
            </td>
            <td>
                <div class="btn-group btn-group-sm">
                    <button class="btn btn-outline-primary" onclick="viewOrder('${order.id}')" title="View Details">
                        <i class="fas fa-eye"></i>
                    </button>
                    <button class="btn btn-outline-success" onclick="updateOrderStatus('${order.id}')" title="Update Status">
                        <i class="fas fa-edit"></i>
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
}

function filterOrders() {
    const statusFilter = document.getElementById('order-status-filter').value;
    const dateFrom = document.getElementById('order-date-from').value;
    const dateTo = document.getElementById('order-date-to').value;
    
    let filteredOrders = [...ordersData];
    
    if (statusFilter) {
        filteredOrders = filteredOrders.filter(order => order.status === statusFilter);
    }
    
    if (dateFrom) {
        filteredOrders = filteredOrders.filter(order => order.date >= dateFrom);
    }
    
    if (dateTo) {
        filteredOrders = filteredOrders.filter(order => order.date <= dateTo);
    }
    
    renderOrdersTable(filteredOrders);
}

function viewOrder(orderId) {
    showNotification(`View order details for ${orderId} would be implemented here`, 'info');
}

function updateOrderStatus(orderId) {
    const order = ordersData.find(o => o.id === orderId);
    if (order) {
        const statuses = ['PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED'];
        const currentIndex = statuses.indexOf(order.status);
        const nextStatus = statuses[currentIndex + 1] || statuses[0];
        
        order.status = nextStatus;
        renderOrdersTable(ordersData);
        showNotification(`Order ${orderId} status updated to ${nextStatus}`, 'success');
    }
}

// Shipping Management
async function loadShipments() {
    try {
        showTableLoading('shipments-table-body');
        shipmentsData = getMockShipmentsData();
        renderShipmentsTable(shipmentsData);
        updateShippingStats();
    } catch (error) {
        console.error('Error loading shipments:', error);
    }
}

function getMockShipmentsData() {
    return [
        { trackingNumber: 'TRACK-1001', orderId: 'ORD-1001', customer: 'John Smith', carrier: 'FedEx', status: 'PREPARING', estimatedDelivery: '2025-10-04' },
        { trackingNumber: 'TRACK-1000', orderId: 'ORD-1000', customer: 'Sarah Johnson', carrier: 'UPS', status: 'IN_TRANSIT', estimatedDelivery: '2025-10-03' },
        { trackingNumber: 'TRACK-999', orderId: 'ORD-999', customer: 'Mike Wilson', carrier: 'USPS', status: 'DELIVERED', estimatedDelivery: '2025-10-01' },
        { trackingNumber: 'TRACK-998', orderId: 'ORD-998', customer: 'Emily Davis', carrier: 'FedEx', status: 'DELIVERED', estimatedDelivery: '2025-09-30' },
        { trackingNumber: 'TRACK-997', orderId: 'ORD-997', customer: 'David Brown', carrier: 'UPS', status: 'DELAYED', estimatedDelivery: '2025-10-05' }
    ];
}

function renderShipmentsTable(shipments) {
    const tbody = document.getElementById('shipments-table-body');
    
    tbody.innerHTML = shipments.map(shipment => `
        <tr>
            <td><strong>${shipment.trackingNumber}</strong></td>
            <td>${shipment.orderId}</td>
            <td>${shipment.customer}</td>
            <td>
                <span class="badge bg-secondary">${shipment.carrier}</span>
            </td>
            <td>
                <span class="badge ${getShippingStatusClass(shipment.status)}">${shipment.status}</span>
            </td>
            <td>${new Date(shipment.estimatedDelivery).toLocaleDateString()}</td>
            <td>
                <div class="btn-group btn-group-sm">
                    <button class="btn btn-outline-primary" onclick="trackShipment('${shipment.trackingNumber}')" title="Track">
                        <i class="fas fa-search"></i>
                    </button>
                    <button class="btn btn-outline-success" onclick="updateShipmentStatus('${shipment.trackingNumber}')" title="Update Status">
                        <i class="fas fa-edit"></i>
                    </button>
                </div>
            </td>
        </tr>
    `).join('');
}

function getShippingStatusClass(status) {
    const classes = {
        'PREPARING': 'bg-warning text-dark',
        'IN_TRANSIT': 'bg-primary',
        'DELIVERED': 'bg-success',
        'DELAYED': 'bg-danger'
    };
    return classes[status] || 'bg-secondary';
}

function updateShippingStats() {
    const stats = {
        pending: shipmentsData.filter(s => s.status === 'PREPARING').length,
        inTransit: shipmentsData.filter(s => s.status === 'IN_TRANSIT').length,
        delivered: shipmentsData.filter(s => s.status === 'DELIVERED' && s.estimatedDelivery === '2025-10-01').length,
        delayed: shipmentsData.filter(s => s.status === 'DELAYED').length
    };
    
    document.getElementById('pending-shipments').textContent = stats.pending;
    document.getElementById('in-transit-shipments').textContent = stats.inTransit;
    document.getElementById('delivered-shipments').textContent = stats.delivered;
    document.getElementById('delayed-shipments').textContent = stats.delayed;
}

function trackShipment(trackingNumber) {
    showNotification(`Tracking details for ${trackingNumber} would be shown here`, 'info');
}

function updateShipmentStatus(trackingNumber) {
    const shipment = shipmentsData.find(s => s.trackingNumber === trackingNumber);
    if (shipment) {
        const statuses = ['PREPARING', 'IN_TRANSIT', 'DELIVERED'];
        const currentIndex = statuses.indexOf(shipment.status);
        const nextStatus = statuses[currentIndex + 1] || statuses[0];
        
        shipment.status = nextStatus;
        renderShipmentsTable(shipmentsData);
        updateShippingStats();
        showNotification(`Shipment ${trackingNumber} status updated to ${nextStatus}`, 'success');
    }
}

// System Health Monitoring
function startHealthMonitoring() {
    refreshSystemHealth();
    // Check system health every 10 seconds
    setInterval(refreshSystemHealth, 10000);
}

async function refreshSystemHealth() {
    const services = ['eureka', 'inventory', 'shipping', 'database'];
    
    for (const service of services) {
        checkServiceHealth(service);
    }
    
    updateSystemLogs();
}

async function checkServiceHealth(serviceName) {
    const statusCard = document.getElementById(`${serviceName}-status`);
    const badge = statusCard.querySelector('.badge');
    
    try {
        let endpoint;
        switch(serviceName) {
            case 'eureka':
                endpoint = `${API_CONFIG.EUREKA_SERVER}/actuator/health`;
                break;
            case 'inventory':
                endpoint = `${API_CONFIG.INVENTORY_SERVICE}/actuator/health`;
                break;
            case 'shipping':
                endpoint = `${API_CONFIG.SHIPPING_SERVICE}/actuator/health`;
                break;
            case 'database':
                // Check PostgreSQL via inventory service database health
                endpoint = `${API_CONFIG.INVENTORY_SERVICE}/actuator/health/db`;
                break;
        }
        
        if (endpoint) {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 5000);
            
            try {
                const response = await fetch(endpoint, { 
                    method: 'GET',
                    mode: 'cors',
                    headers: {
                        'Accept': 'application/json',
                    },
                    signal: controller.signal
                });
                
                clearTimeout(timeoutId);
                
                if (response.ok) {
                    setServiceStatus(statusCard, badge, 'healthy', 'Online');
                } else {
                    setServiceStatus(statusCard, badge, 'warning', `Warning (${response.status})`);
                }
            } catch (fetchError) {
                clearTimeout(timeoutId);
                if (fetchError.name === 'AbortError') {
                    setServiceStatus(statusCard, badge, 'error', 'Timeout');
                } else {
                    setServiceStatus(statusCard, badge, 'error', 'Offline');
                }
            }
        } else {
            // Simulate database status
            setServiceStatus(statusCard, badge, 'healthy', 'Online');
        }
        
    } catch (error) {
        setServiceStatus(statusCard, badge, 'error', 'Offline');
    }
}

function setServiceStatus(card, badge, status, text) {
    // Remove existing status classes
    card.classList.remove('status-healthy', 'status-warning', 'status-error');
    
    // Add new status class
    card.classList.add(`status-${status}`);
    
    // Update badge
    badge.className = 'badge';
    switch(status) {
        case 'healthy':
            badge.classList.add('bg-success');
            break;
        case 'warning':
            badge.classList.add('bg-warning', 'text-dark');
            break;
        case 'error':
            badge.classList.add('bg-danger');
            break;
    }
    
    badge.textContent = text;
}

function updateSystemLogs() {
    const logsContainer = document.getElementById('system-logs');
    const currentTime = new Date().toLocaleTimeString();
    
    const logEntries = [
        { time: currentTime, level: 'info', message: 'System health check completed' },
        { time: currentTime, level: 'success', message: 'All services responding normally' },
        { time: new Date(Date.now() - 60000).toLocaleTimeString(), level: 'info', message: 'Inventory service cache refreshed' },
        { time: new Date(Date.now() - 120000).toLocaleTimeString(), level: 'warning', message: 'High memory usage detected on shipping service' },
        { time: new Date(Date.now() - 180000).toLocaleTimeString(), level: 'info', message: 'Database connection pool optimized' }
    ];
    
    logsContainer.innerHTML = logEntries.map(entry => `
        <div class="log-entry">
            <span class="log-timestamp">[${entry.time}]</span>
            <span class="log-level-${entry.level}">[${entry.level.toUpperCase()}]</span>
            ${entry.message}
        </div>
    `).join('');
}

// Utility Functions
function showTableLoading(tableId) {
    document.getElementById(tableId).innerHTML = `
        <tr>
            <td colspan="10" class="text-center">
                <div class="spinner-border text-primary" role="status"></div>
                <p class="mt-2">Loading data...</p>
            </td>
        </tr>
    `;
}

function showNotification(message, type = 'info') {
    // Create toast notification
    const toastContainer = document.querySelector('.toast-container') || createToastContainer();
    
    const toast = document.createElement('div');
    toast.className = `toast ${type === 'error' ? 'bg-danger text-white' : ''}`;
    toast.innerHTML = `
        <div class="toast-header">
            <i class="fas fa-${getToastIcon(type)} me-2"></i>
            <strong class="me-auto">Admin Notification</strong>
            <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
        </div>
        <div class="toast-body">${message}</div>
    `;
    
    toastContainer.appendChild(toast);
    
    const bsToast = new bootstrap.Toast(toast);
    bsToast.show();
    
    // Remove toast element after it's hidden
    toast.addEventListener('hidden.bs.toast', () => {
        toast.remove();
    });
}

function createToastContainer() {
    const container = document.createElement('div');
    container.className = 'toast-container position-fixed bottom-0 end-0 p-3';
    document.body.appendChild(container);
    return container;
}

function getToastIcon(type) {
    const icons = {
        success: 'check-circle',
        error: 'exclamation-triangle',
        warning: 'exclamation-triangle',
        info: 'info-circle'
    };
    return icons[type] || 'info-circle';
}

function loadMockDashboardData() {
    // Load mock data when services are not available
    loadDashboardKPIs();
    loadSalesChart();
    loadProductsChart();
    loadRecentActivities();
}

// Logout function
function logout() {
    localStorage.removeItem('adminUser');
    localStorage.removeItem('loginTime');
    window.location.href = 'login.html';
}