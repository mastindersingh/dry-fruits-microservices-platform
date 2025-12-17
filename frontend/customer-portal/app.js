// Customer Portal JavaScript - Main Application Logic

// API Configuration - External Routes for Browser Access
const API_CONFIG = {
    BASE_URL: 'https://api-gateway-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com', // API Gateway
    INVENTORY_SERVICE: 'https://inventory-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com',
    SHIPPING_SERVICE: 'https://shipping-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com',
    ORDER_SERVICE: 'https://order-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com',
    USER_SERVICE: 'https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com',
    PAYMENT_SERVICE: 'https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com'
};

// Application State
let currentUser = JSON.parse(localStorage.getItem('currentUser')) || null;
let authToken = localStorage.getItem('authToken') || null;
let cart = JSON.parse(localStorage.getItem('cart')) || [];
let products = [];
let orders = [];

// ========================================
// AUTHENTICATION FUNCTIONS
// ========================================

function showLoginModal(e) {
    e.preventDefault();
    const loginModal = new bootstrap.Modal(document.getElementById('loginModal'));
    loginModal.show();
}

function switchToRegister() {
    bootstrap.Modal.getInstance(document.getElementById('loginModal')).hide();
    const registerModal = new bootstrap.Modal(document.getElementById('registerModal'));
    registerModal.show();
}

function switchToLogin() {
    bootstrap.Modal.getInstance(document.getElementById('registerModal')).hide();
    const loginModal = new bootstrap.Modal(document.getElementById('loginModal'));
    loginModal.show();
}

async function handleLogin(e) {
    e.preventDefault();
    
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;
    const errorDiv = document.getElementById('loginError');
    
    try {
        const response = await fetch(`${API_CONFIG.USER_SERVICE}/api/v1/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ email, password })
        });
        
        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.error || 'Login failed');
        }
        
        // Save user data and token
        currentUser = {
            id: data.userId,
            email: data.email,
            name: data.name,
            role: data.role
        };
        authToken = data.token;
        
        localStorage.setItem('currentUser', JSON.stringify(currentUser));
        localStorage.setItem('authToken', authToken);
        
        // Hide modal and update UI
        bootstrap.Modal.getInstance(document.getElementById('loginModal')).hide();
        updateAuthUI();
        showNotification(`Welcome back, ${currentUser.name}!`, 'success');
        
        // Reset form
        document.getElementById('loginForm').reset();
        errorDiv.classList.add('d-none');
        
    } catch (error) {
        errorDiv.textContent = error.message;
        errorDiv.classList.remove('d-none');
    }
}

async function handleRegister(e) {
    e.preventDefault();
    
    const name = document.getElementById('registerName').value;
    const email = document.getElementById('registerEmail').value;
    const password = document.getElementById('registerPassword').value;
    const passwordConfirm = document.getElementById('registerPasswordConfirm').value;
    const errorDiv = document.getElementById('registerError');
    
    // Validate password match
    if (password !== passwordConfirm) {
        errorDiv.textContent = 'Passwords do not match';
        errorDiv.classList.remove('d-none');
        return;
    }
    
    try {
        const response = await fetch(`${API_CONFIG.USER_SERVICE}/api/v1/auth/register`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ name, email, password })
        });
        
        const data = await response.json();
        
        if (!response.ok) {
            throw new Error(data.error || 'Registration failed');
        }
        
        // Save user data and token
        currentUser = {
            id: data.userId,
            email: data.email,
            name: data.name,
            role: data.role
        };
        authToken = data.token;
        
        localStorage.setItem('currentUser', JSON.stringify(currentUser));
        localStorage.setItem('authToken', authToken);
        
        // Hide modal and update UI
        bootstrap.Modal.getInstance(document.getElementById('registerModal')).hide();
        updateAuthUI();
        showNotification(`Welcome, ${currentUser.name}! Your account has been created.`, 'success');
        
        // Reset form
        document.getElementById('registerForm').reset();
        errorDiv.classList.add('d-none');
        
    } catch (error) {
        errorDiv.textContent = error.message;
        errorDiv.classList.remove('d-none');
    }
}

function logout() {
    currentUser = null;
    authToken = null;
    localStorage.removeItem('currentUser');
    localStorage.removeItem('authToken');
    updateAuthUI();
    showNotification('Logged out successfully', 'info');
}

function updateAuthUI() {
    const authNav = document.getElementById('auth-nav');
    
    if (currentUser) {
        authNav.innerHTML = `
            <div class="dropdown">
                <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                    <i class="fas fa-user-circle"></i> ${currentUser.name}
                </a>
                <ul class="dropdown-menu dropdown-menu-end">
                    <li><a class="dropdown-item" href="#profile"><i class="fas fa-user"></i> Profile</a></li>
                    <li><a class="dropdown-item" href="#orders"><i class="fas fa-box"></i> My Orders</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item" href="#" onclick="logout()"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
                </ul>
            </div>
        `;
    } else {
        authNav.innerHTML = `
            <a class="nav-link" href="#" onclick="showLoginModal(event)">
                <i class="fas fa-user"></i> Login
            </a>
        `;
    }
}

// Helper function to add auth header to requests
function getAuthHeaders() {
    const headers = {
        'Content-Type': 'application/json'
    };
    
    if (authToken) {
        headers['Authorization'] = `Bearer ${authToken}`;
    }
    
    return headers;
}

// Initialize Application
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    setupEventListeners();
    updateAuthUI();  // Update auth UI on page load
    loadProducts();
    updateCartCount();
});

function initializeApp() {
    console.log('🚀 Customer Portal Initialized');
    if (currentUser) {
        showNotification(`Welcome back, ${currentUser.name}!`, 'success');
    } else {
        showNotification('Welcome to Premium Dry Fruits!', 'success');
    }
}

function setupEventListeners() {
    // Navigation
    document.querySelectorAll('.nav-link').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const target = this.getAttribute('href').substring(1);
            showSection(target);
        });
    });

    // Search functionality
    document.getElementById('searchProducts').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            searchProducts();
        }
    });
}

function showSection(sectionId) {
    // Hide all sections
    document.querySelectorAll('section').forEach(section => {
        section.style.display = 'none';
    });

    // Show target section
    const targetSection = document.getElementById(sectionId);
    if (targetSection) {
        targetSection.style.display = 'block';
        
        // Load section-specific data
        switch(sectionId) {
            case 'orders':
                loadOrders();
                break;
            case 'cart':
                renderCart();
                break;
        }
    } else {
        // Show home section by default
        document.getElementById('home').style.display = 'block';
        document.getElementById('products').style.display = 'block';
    }

    // Update navigation
    document.querySelectorAll('.nav-link').forEach(link => {
        link.classList.remove('active');
    });
    document.querySelector(`[href="#${sectionId}"]`)?.classList.add('active');
}

// Product Management
async function loadProducts() {
    try {
        showLoadingSpinner('products-grid');
        
        // Try to fetch from inventory service
        const response = await fetch(`${API_CONFIG.INVENTORY_SERVICE}/inventory/v1/items`);
        
        if (response.ok) {
            products = await response.json();
        } else {
            // Fallback to mock data if service is not available
            products = getMockProducts();
        }
        
        renderProducts(products);
        
    } catch (error) {
        console.warn('⚠️ Inventory service not available, using mock data');
        products = getMockProducts();
        renderProducts(products);
    }
}

function getMockProducts() {
    return [
        {
            id: 1,
            productId: 'ALM001',
            productName: 'Premium Almonds',
            category: 'NUTS',
            quantity: 100,
            unitPrice: 25.99,
            description: 'Fresh, premium quality almonds sourced from California orchards.',
            imageUrl: 'https://images.unsplash.com/photo-1508747703725-719777637510?w=300'
        },
        {
            id: 2,
            productId: 'WAL001',
            productName: 'Organic Walnuts',
            category: 'NUTS',
            quantity: 75,
            unitPrice: 32.50,
            description: 'Organic walnuts rich in omega-3 fatty acids.',
            imageUrl: 'https://images.unsplash.com/photo-1553909489-cd47e0ef937f?w=300'
        },
        {
            id: 3,
            productId: 'FIG001',
            productName: 'Turkish Figs',
            category: 'DRIED_FRUITS',
            quantity: 50,
            unitPrice: 28.75,
            description: 'Sweet and chewy Turkish figs, naturally dried.',
            imageUrl: 'https://images.unsplash.com/photo-1577003833619-76bbd7293d82?w=300'
        },
        {
            id: 4,
            productId: 'DAT001',
            productName: 'Medjool Dates',
            category: 'DRIED_FRUITS',
            quantity: 60,
            unitPrice: 35.00,
            description: 'Premium Medjool dates, nature\'s candy.',
            imageUrl: 'https://images.unsplash.com/photo-1591206369811-4eeb2f03bc95?w=300'
        },
        {
            id: 5,
            productId: 'CAS001',
            productName: 'Roasted Cashews',
            category: 'NUTS',
            quantity: 80,
            unitPrice: 42.00,
            description: 'Lightly salted, roasted cashews.',
            imageUrl: 'https://images.unsplash.com/photo-1599599810169-ba47e71266c6?w=300'
        },
        {
            id: 6,
            productId: 'MIX001',
            productName: 'Trail Mix Supreme',
            category: 'MIXED',
            quantity: 40,
            unitPrice: 24.99,
            description: 'Perfect blend of nuts, dried fruits, and seeds.',
            imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=300'
        }
    ];
}

function renderProducts(productsToRender) {
    const grid = document.getElementById('products-grid');
    
    if (productsToRender.length === 0) {
        grid.innerHTML = `
            <div class="col-12 text-center">
                <i class="fas fa-search fa-3x text-muted mb-3"></i>
                <h4 class="text-muted">No products found</h4>
                <p class="text-muted">Try adjusting your search or filter criteria.</p>
            </div>
        `;
        return;
    }

    grid.innerHTML = productsToRender.map(product => `
        <div class="col-lg-4 col-md-6 mb-4">
            <div class="card product-card h-100">
                <div class="position-relative">
                    <img src="${product.imageUrl || 'https://via.placeholder.com/300x200?text=Product'}" 
                         class="card-img-top product-image" alt="${product.productName}">
                    <span class="badge ${getStockBadgeClass(product.quantity)} stock-badge">
                        ${getStockText(product.quantity)}
                    </span>
                </div>
                <div class="card-body d-flex flex-column">
                    <h5 class="card-title">${product.productName}</h5>
                    <p class="card-text text-muted small">${product.description || 'Premium quality product'}</p>
                    <div class="mt-auto">
                        <div class="d-flex justify-content-between align-items-center mb-2">
                            <span class="price-tag">$${product.unitPrice.toFixed(2)}</span>
                            <small class="text-muted">${product.category}</small>
                        </div>
                        <div class="d-flex gap-2">
                            <button class="btn btn-success flex-fill" 
                                    onclick="addToCart(${product.id})"
                                    ${product.quantity === 0 ? 'disabled' : ''}>
                                <i class="fas fa-cart-plus"></i> Add to Cart
                            </button>
                            <button class="btn btn-outline-success" 
                                    onclick="checkStock(${product.id})"
                                    title="Check Stock">
                                <i class="fas fa-warehouse"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `).join('');

    // Add fade-in animation
    grid.querySelectorAll('.product-card').forEach((card, index) => {
        setTimeout(() => {
            card.classList.add('fade-in');
        }, index * 100);
    });
}

function getStockBadgeClass(quantity) {
    if (quantity === 0) return 'bg-danger';
    if (quantity < 20) return 'bg-warning text-dark';
    return 'bg-success';
}

function getStockText(quantity) {
    if (quantity === 0) return 'Out of Stock';
    if (quantity < 20) return 'Low Stock';
    return 'In Stock';
}

async function checkStock(productId) {
    try {
        const product = products.find(p => p.id === productId);
        if (!product) return;

        // Try to get real-time stock data
        const response = await fetch(`${API_CONFIG.INVENTORY_SERVICE}/inventory/v1/availability/${product.productId}/1`);
        
        let stockInfo;
        if (response.ok) {
            stockInfo = await response.json();
        } else {
            stockInfo = { available: product.quantity > 0, quantity: product.quantity };
        }

        showNotification(
            `${product.productName}: ${stockInfo.quantity || product.quantity} units available`,
            stockInfo.available ? 'success' : 'warning'
        );
        
    } catch (error) {
        console.error('Error checking stock:', error);
        showNotification('Unable to check stock at this time', 'error');
    }
}

// Search and Filter Functions
function searchProducts() {
    const searchTerm = document.getElementById('searchProducts').value.toLowerCase();
    const filteredProducts = products.filter(product => 
        product.productName.toLowerCase().includes(searchTerm) ||
        product.description?.toLowerCase().includes(searchTerm) ||
        product.category.toLowerCase().includes(searchTerm)
    );
    renderProducts(filteredProducts);
}

function filterByCategory() {
    const category = document.getElementById('categoryFilter').value;
    const filteredProducts = category 
        ? products.filter(product => product.category === category)
        : products;
    renderProducts(filteredProducts);
}

// Cart Management
function addToCart(productId) {
    const product = products.find(p => p.id === productId);
    if (!product || product.quantity === 0) {
        showNotification('Product is out of stock', 'error');
        return;
    }

    const existingItem = cart.find(item => item.id === productId);
    if (existingItem) {
        existingItem.quantity += 1;
    } else {
        cart.push({
            id: productId,
            productId: product.productId,
            productName: product.productName,
            unitPrice: product.unitPrice,
            quantity: 1,
            imageUrl: product.imageUrl
        });
    }

    localStorage.setItem('cart', JSON.stringify(cart));
    updateCartCount();
    showNotification(`${product.productName} added to cart!`, 'success');
}

function removeFromCart(productId) {
    cart = cart.filter(item => item.id !== productId);
    localStorage.setItem('cart', JSON.stringify(cart));
    updateCartCount();
    renderCart();
    showNotification('Item removed from cart', 'info');
}

function updateQuantity(productId, newQuantity) {
    if (newQuantity <= 0) {
        removeFromCart(productId);
        return;
    }

    const item = cart.find(item => item.id === productId);
    if (item) {
        item.quantity = newQuantity;
        localStorage.setItem('cart', JSON.stringify(cart));
        updateCartCount();
        renderCart();
    }
}

function updateCartCount() {
    const totalItems = cart.reduce((sum, item) => sum + item.quantity, 0);
    document.getElementById('cart-count').textContent = totalItems;
}

function renderCart() {
    const cartContainer = document.getElementById('cart-items');
    const subtotalElement = document.getElementById('cart-subtotal');
    const shippingElement = document.getElementById('cart-shipping');
    const totalElement = document.getElementById('cart-total');

    if (cart.length === 0) {
        cartContainer.innerHTML = `
            <div class="text-center py-5">
                <i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i>
                <h4 class="text-muted">Your cart is empty</h4>
                <p class="text-muted">Start shopping to add items to your cart.</p>
                <button class="btn btn-success" onclick="scrollToProducts()">
                    <i class="fas fa-shopping-bag"></i> Start Shopping
                </button>
            </div>
        `;
        subtotalElement.textContent = '$0.00';
        totalElement.textContent = '$5.99';
        return;
    }

    cartContainer.innerHTML = cart.map(item => `
        <div class="cart-item">
            <div class="row align-items-center">
                <div class="col-md-2">
                    <img src="${item.imageUrl || 'https://via.placeholder.com/100'}" 
                         class="img-fluid rounded" alt="${item.productName}">
                </div>
                <div class="col-md-4">
                    <h6 class="mb-0">${item.productName}</h6>
                    <small class="text-muted">Product ID: ${item.productId}</small>
                </div>
                <div class="col-md-2">
                    <span class="fw-bold">$${item.unitPrice.toFixed(2)}</span>
                </div>
                <div class="col-md-2">
                    <div class="quantity-controls">
                        <button class="quantity-btn" onclick="updateQuantity(${item.id}, ${item.quantity - 1})">
                            <i class="fas fa-minus"></i>
                        </button>
                        <span class="mx-2">${item.quantity}</span>
                        <button class="quantity-btn" onclick="updateQuantity(${item.id}, ${item.quantity + 1})">
                            <i class="fas fa-plus"></i>
                        </button>
                    </div>
                </div>
                <div class="col-md-1">
                    <span class="fw-bold">$${(item.unitPrice * item.quantity).toFixed(2)}</span>
                </div>
                <div class="col-md-1">
                    <button class="btn btn-outline-danger btn-sm" onclick="removeFromCart(${item.id})">
                        <i class="fas fa-trash"></i>
                    </button>
                </div>
            </div>
        </div>
    `).join('');

    // Calculate totals
    const subtotal = cart.reduce((sum, item) => sum + (item.unitPrice * item.quantity), 0);
    const shipping = subtotal > 50 ? 0 : 5.99;
    const total = subtotal + shipping;

    subtotalElement.textContent = `$${subtotal.toFixed(2)}`;
    shippingElement.textContent = shipping === 0 ? 'FREE' : `$${shipping.toFixed(2)}`;
    totalElement.textContent = `$${total.toFixed(2)}`;
}

async function checkout() {
    if (cart.length === 0) {
        showNotification('Your cart is empty', 'error');
        return;
    }

    if (!currentUser) {
        showNotification('Please login to proceed with checkout', 'error');
        showLoginModal(new Event('click'));
        return;
    }

    // Show payment modal
    const paymentModal = new bootstrap.Modal(document.getElementById('paymentModal'));
    paymentModal.show();
}

async function processPayment(e) {
    e.preventDefault();
    
    const cardNumber = document.getElementById('cardNumber').value.replace(/\s/g, '');
    const cardName = document.getElementById('cardName').value;
    const expiryDate = document.getElementById('expiryDate').value;
    const cvv = document.getElementById('cvv').value;
    
    // Parse expiry date
    const [month, year] = expiryDate.split('/');
    const fullYear = '20' + year;
    
    // Calculate total
    const subtotal = cart.reduce((sum, item) => sum + (item.unitPrice * item.quantity), 0);
    const shipping = subtotal > 50 ? 0 : 5.99;
    const total = subtotal + shipping;
    
    try {
        showLoadingOverlay('Processing payment...');
        
        const paymentData = {
            orderId: Date.now(), // Temporary order ID
            userId: currentUser.userId,
            amount: total,
            currency: 'USD',
            paymentMethod: 'CREDIT_CARD',
            cardNumber: cardNumber,
            cardHolderName: cardName,
            expiryMonth: month.padStart(2, '0'),
            expiryYear: fullYear,
            cvv: cvv
        };
        
        const response = await fetch(`${API_CONFIG.PAYMENT_SERVICE}/api/v1/payments/process`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                ...getAuthHeaders()
            },
            body: JSON.stringify(paymentData)
        });
        
        const result = await response.json();
        
        if (response.ok && result.status === 'COMPLETED') {
            // Payment successful - clear cart
            cart = [];
            localStorage.setItem('cart', JSON.stringify(cart));
            updateCartCount();
            
            // Hide payment modal
            bootstrap.Modal.getInstance(document.getElementById('paymentModal')).hide();
            
            hideLoadingOverlay();
            showNotification(`Payment successful! Transaction ID: ${result.transactionId}`, 'success');
            
            // Redirect to orders
            showSection('orders');
        } else {
            hideLoadingOverlay();
            showNotification(result.failureReason || 'Payment failed. Please try again.', 'error');
        }
        
    } catch (error) {
        hideLoadingOverlay();
        console.error('Payment error:', error);
        showNotification('Unable to process payment. Please try again.', 'error');
    }
}

// Orders Management
async function loadOrders() {
    try {
        showLoadingSpinner('orders-list');
        
        // Try to fetch real orders or use mock data
        orders = getMockOrders();
        renderOrders(orders);
        
    } catch (error) {
        console.error('Error loading orders:', error);
        orders = getMockOrders();
        renderOrders(orders);
    }
}

function getMockOrders() {
    return [
        {
            id: 'ORD-001',
            date: '2025-09-28',
            status: 'DELIVERED',
            total: 67.49,
            trackingNumber: 'TRACK-001',
            items: [
                { productName: 'Premium Almonds', quantity: 2, price: 25.99 },
                { productName: 'Organic Walnuts', quantity: 1, price: 32.50 }
            ]
        },
        {
            id: 'ORD-002',
            date: '2025-09-30',
            status: 'SHIPPED',
            total: 63.75,
            trackingNumber: 'TRACK-002',
            items: [
                { productName: 'Turkish Figs', quantity: 1, price: 28.75 },
                { productName: 'Medjool Dates', quantity: 1, price: 35.00 }
            ]
        },
        {
            id: 'ORD-003',
            date: '2025-10-01',
            status: 'PROCESSING',
            total: 42.00,
            trackingNumber: null,
            items: [
                { productName: 'Roasted Cashews', quantity: 1, price: 42.00 }
            ]
        }
    ];
}

function renderOrders(ordersToRender) {
    const container = document.getElementById('orders-list');
    
    if (ordersToRender.length === 0) {
        container.innerHTML = `
            <div class="text-center py-5">
                <i class="fas fa-receipt fa-3x text-muted mb-3"></i>
                <h4 class="text-muted">No orders found</h4>
                <p class="text-muted">You haven't placed any orders yet.</p>
                <button class="btn btn-success" onclick="scrollToProducts()">
                    <i class="fas fa-shopping-bag"></i> Start Shopping
                </button>
            </div>
        `;
        return;
    }

    container.innerHTML = ordersToRender.map(order => `
        <div class="card mb-3">
            <div class="card-header d-flex justify-content-between align-items-center">
                <div>
                    <h5 class="mb-0">Order ${order.id}</h5>
                    <small class="text-muted">Placed on ${new Date(order.date).toLocaleDateString()}</small>
                </div>
                <div class="text-end">
                    <span class="order-status status-${order.status.toLowerCase()}">${order.status}</span>
                    <div class="mt-1">
                        <strong>$${order.total.toFixed(2)}</strong>
                    </div>
                </div>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-8">
                        <h6>Items:</h6>
                        <ul class="list-unstyled mb-0">
                            ${order.items.map(item => `
                                <li class="d-flex justify-content-between">
                                    <span>${item.productName} × ${item.quantity}</span>
                                    <span>$${(item.price * item.quantity).toFixed(2)}</span>
                                </li>
                            `).join('')}
                        </ul>
                    </div>
                    <div class="col-md-4 text-end">
                        ${order.trackingNumber ? `
                            <button class="btn btn-outline-success btn-sm mb-2" 
                                    onclick="trackOrder('${order.trackingNumber}')">
                                <i class="fas fa-truck"></i> Track Package
                            </button>
                        ` : ''}
                        <button class="btn btn-success btn-sm d-block" 
                                onclick="reorderItems('${order.id}')">
                            <i class="fas fa-redo"></i> Reorder
                        </button>
                    </div>
                </div>
            </div>
        </div>
    `).join('');
}

async function trackOrder(trackingNumber) {
    try {
        const modal = new bootstrap.Modal(document.getElementById('trackingModal'));
        modal.show();
        
        // Simulate loading
        document.getElementById('tracking-content').innerHTML = `
            <div class="text-center">
                <div class="spinner-border text-success" role="status"></div>
                <p class="mt-2">Loading tracking information...</p>
            </div>
        `;

        // Simulate API call
        await new Promise(resolve => setTimeout(resolve, 1500));
        
        // Show mock tracking data
        const trackingData = getMockTrackingData(trackingNumber);
        renderTrackingInfo(trackingData);
        
    } catch (error) {
        console.error('Error tracking order:', error);
        document.getElementById('tracking-content').innerHTML = `
            <div class="text-center text-danger">
                <i class="fas fa-exclamation-triangle fa-2x mb-2"></i>
                <p>Unable to load tracking information</p>
            </div>
        `;
    }
}

function getMockTrackingData(trackingNumber) {
    return {
        trackingNumber: trackingNumber,
        status: 'In Transit',
        estimatedDelivery: '2025-10-03',
        currentLocation: 'Distribution Center - New York',
        timeline: [
            { date: '2025-09-30', time: '10:30 AM', status: 'Order Confirmed', location: 'Warehouse', completed: true },
            { date: '2025-09-30', time: '2:15 PM', status: 'Package Prepared', location: 'Warehouse', completed: true },
            { date: '2025-10-01', time: '8:00 AM', status: 'In Transit', location: 'Distribution Center - NY', completed: true, active: true },
            { date: '2025-10-02', time: 'Expected', status: 'Out for Delivery', location: 'Local Facility', completed: false },
            { date: '2025-10-03', time: 'Expected', status: 'Delivered', location: 'Your Address', completed: false }
        ]
    };
}

function renderTrackingInfo(trackingData) {
    document.getElementById('tracking-content').innerHTML = `
        <div class="row mb-4">
            <div class="col-md-6">
                <h6><i class="fas fa-barcode"></i> Tracking Number</h6>
                <p class="mb-0">${trackingData.trackingNumber}</p>
            </div>
            <div class="col-md-6">
                <h6><i class="fas fa-calendar"></i> Estimated Delivery</h6>
                <p class="mb-0">${new Date(trackingData.estimatedDelivery).toLocaleDateString()}</p>
            </div>
        </div>
        
        <div class="mb-4">
            <h6><i class="fas fa-map-marker-alt"></i> Current Status</h6>
            <div class="alert alert-success">
                <strong>${trackingData.status}</strong> - ${trackingData.currentLocation}
            </div>
        </div>
        
        <h6><i class="fas fa-route"></i> Tracking Timeline</h6>
        <div class="tracking-timeline">
            ${trackingData.timeline.map(step => `
                <div class="tracking-step ${step.completed ? 'completed' : ''} ${step.active ? 'active' : ''}">
                    <div class="d-flex justify-content-between">
                        <div>
                            <strong>${step.status}</strong>
                            <div class="text-muted small">${step.location}</div>
                        </div>
                        <div class="text-end text-muted small">
                            <div>${step.date}</div>
                            <div>${step.time}</div>
                        </div>
                    </div>
                </div>
            `).join('')}
        </div>
    `;
}

function reorderItems(orderId) {
    const order = orders.find(o => o.id === orderId);
    if (!order) return;

    // Add items to cart
    order.items.forEach(item => {
        const product = products.find(p => p.productName === item.productName);
        if (product) {
            const existingItem = cart.find(cartItem => cartItem.id === product.id);
            if (existingItem) {
                existingItem.quantity += item.quantity;
            } else {
                cart.push({
                    id: product.id,
                    productId: product.productId,
                    productName: product.productName,
                    unitPrice: product.unitPrice,
                    quantity: item.quantity,
                    imageUrl: product.imageUrl
                });
            }
        }
    });

    localStorage.setItem('cart', JSON.stringify(cart));
    updateCartCount();
    showNotification(`Items from order ${orderId} added to cart!`, 'success');
}

// Utility Functions
function scrollToProducts() {
    document.getElementById('products').scrollIntoView({ behavior: 'smooth' });
    showSection('home');
}

function showLoadingSpinner(containerId) {
    const container = document.getElementById(containerId);
    container.innerHTML = `
        <div class="col-12 text-center">
            <div class="spinner-border text-success" role="status">
                <span class="visually-hidden">Loading...</span>
            </div>
            <p class="mt-2">Loading...</p>
        </div>
    `;
}

function showLoadingOverlay(message = 'Loading...') {
    const overlay = document.createElement('div');
    overlay.className = 'loading-overlay';
    overlay.id = 'loading-overlay';
    overlay.innerHTML = `
        <div class="text-center text-white">
            <div class="spinner-border mb-3" role="status"></div>
            <h5>${message}</h5>
        </div>
    `;
    document.body.appendChild(overlay);
}

function hideLoadingOverlay() {
    const overlay = document.getElementById('loading-overlay');
    if (overlay) {
        overlay.remove();
    }
}

function showNotification(message, type = 'info') {
    const toast = document.getElementById('notification-toast');
    const toastMessage = document.getElementById('toast-message');
    
    toastMessage.textContent = message;
    
    // Update toast styling based on type
    toast.className = `toast ${type === 'error' ? 'bg-danger text-white' : ''}`;
    
    const bsToast = new bootstrap.Toast(toast);
    bsToast.show();
}