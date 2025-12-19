# 🌐 Complete URL Testing Guide - Dry Fruits Platform

## 📋 All Application URLs

### 🛍️ Customer Portal (Main Application)
```
https://customer-portal-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```
**What to test:**
- ✅ Homepage loads with hero section
- ✅ Product listing displays
- ✅ Login/Register functionality
- ✅ Add to cart
- ✅ View cart with order summary
- ✅ **NEW: Checkout flow with shipping address**
- ✅ **NEW: Payment method selection (Card/COD)**
- ✅ Payment processing with test cards

---

### 👤 User Service API
```
https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```

**Endpoints to test:**

#### 1. Health Check
```bash
GET https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/actuator/health
```
Expected: `{"status":"UP"}`

#### 2. Register New User
```bash
POST https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/auth/register

Body:
{
  "fullName": "Test User",
  "email": "test@example.com",
  "password": "password123"
}
```
Expected: `{"token":"jwt-token-here","userId":1,"email":"test@example.com"}`

#### 3. Login
```bash
POST https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/auth/login

Body:
{
  "email": "test@example.com",
  "password": "password123"
}
```
Expected: JWT token response

---

### 💳 Payment Service API
```
https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```

**Endpoints to test:**

#### 1. Service Info (Root Endpoint)
```bash
GET https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/
```
Expected:
```json
{
  "service": "Payment Service",
  "description": "Mock Payment Gateway API",
  "version": "1.0.0",
  "status": "UP"
}
```

#### 2. Health Check
```bash
GET https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/payments/health
```
Expected: `{"service":"payment-service","status":"UP"}`

#### 3. Test Cards Information
```bash
GET https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/payments/test-cards
```
Expected: List of test cards with success/failure scenarios

#### 4. Process Payment
```bash
POST https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/payments/process

Headers:
Authorization: Bearer <jwt-token>
Content-Type: application/json

Body:
{
  "orderId": 12345,
  "userId": 1,
  "amount": 99.99,
  "currency": "USD",
  "paymentMethod": "CREDIT_CARD",
  "cardNumber": "4111111111111111",
  "cardHolderName": "Test User",
  "expiryMonth": "12",
  "expiryYear": "2027",
  "cvv": "123"
}
```
Expected: `{"status":"COMPLETED","transactionId":"TXN-...",...}`

---

### 🎛️ Admin Dashboard
```
https://admin-dashboard-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```
**What to test:**
- ✅ Dashboard loads
- ✅ Login functionality
- ✅ Admin panel access

---

## 🧪 End-to-End Testing Workflow

### Test 1: Complete Purchase Flow with Credit Card

1. **Open Customer Portal**
   ```
   https://customer-portal-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
   ```

2. **Register/Login**
   - Click "Login" in navbar
   - Register a new account or login with existing credentials

3. **Browse Products**
   - Scroll to "Our Premium Products" section
   - Browse different categories

4. **Add to Cart**
   - Click "Add to Cart" on 2-3 products
   - Cart count should update in navbar

5. **View Cart**
   - Click cart icon in navbar
   - Verify items, quantities, and totals

6. **Proceed to Checkout** ⭐ NEW FLOW
   - Click "Checkout" button
   - **Checkout Modal Opens** with:
     - ✅ Order summary table
     - ✅ Subtotal, shipping, and total
     - ✅ Shipping address form
     - ✅ Payment method selection (Card/COD)

7. **Fill Shipping Information**
   - Full Name: `John Doe`
   - Phone: `555-123-4567`
   - Street Address: `123 Main St`
   - City: `New York`
   - State: `NY`
   - ZIP: `10001`

8. **Select Payment Method**
   - Select "Credit/Debit Card" radio button

9. **Proceed to Payment**
   - Click "Proceed to Payment" button
   - **Payment Modal Opens**

10. **Enter Card Details**
    - Card Number: `4111111111111111`
    - Name: `John Doe`
    - Expiry: `12/27`
    - CVV: `123`

11. **Complete Payment**
    - Click "Pay Now"
    - Wait for processing (~1-2 seconds)
    - Success message with Transaction ID

12. **Verify Results**
    - ✅ Cart cleared (count = 0)
    - ✅ Success notification with transaction ID
    - ✅ Redirected to "My Orders" section

---

### Test 2: Cash on Delivery (COD) ⭐ NEW FEATURE

1. **Follow steps 1-7** from Test 1

2. **Select Payment Method**
   - Select "Cash on Delivery" radio button

3. **Proceed to Payment**
   - Click "Proceed to Payment" button
   - **No payment modal** (COD doesn't require card)

4. **Verify Results**
   - ✅ Order placed successfully
   - ✅ Order ID displayed
   - ✅ Total amount shown for COD payment
   - ✅ Cart cleared

---

### Test 3: Payment Failure Scenario

1. **Follow steps 1-9** from Test 1

2. **Enter Failing Card**
   - Card Number: `4000000000000002` (Insufficient funds)
   - Name: `John Doe`
   - Expiry: `12/27`
   - CVV: `123`

3. **Complete Payment**
   - Click "Pay Now"
   - Wait for processing

4. **Verify Results**
   - ✅ Error message: "Insufficient funds"
   - ✅ Payment modal remains open
   - ✅ Cart NOT cleared
   - ✅ User can retry with different card

---

## 🔐 Test Cards Reference

### ✅ Success Cards (Always Approve)
```
Card Number: 4111111111111111 (Visa)
Card Number: 5555555555554444 (Mastercard)
Card Number: 378282246310005 (American Express)

Expiry: 12/27
CVV: 123
Name: Any name
```

### ❌ Failure Cards (Always Decline)
```
Card Number: 4000000000000002 (Insufficient Funds)
Card Number: 4000000000009995 (Card Declined)

Expiry: 12/27
CVV: 123
Name: Any name
```

---

## 🛠️ Testing with cURL

### Test User Registration
```powershell
curl -k -X POST https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/auth/register `
  -H "Content-Type: application/json" `
  -d '{\"fullName\":\"Test User\",\"email\":\"test@example.com\",\"password\":\"password123\"}'
```

### Test Payment Processing
```powershell
# First, get JWT token from login
$token = "your-jwt-token-here"

curl -k -X POST https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/payments/process `
  -H "Content-Type: application/json" `
  -H "Authorization: Bearer $token" `
  -d '{\"orderId\":12345,\"userId\":1,\"amount\":99.99,\"currency\":\"USD\",\"paymentMethod\":\"CREDIT_CARD\",\"cardNumber\":\"4111111111111111\",\"cardHolderName\":\"Test User\",\"expiryMonth\":\"12\",\"expiryYear\":\"2027\",\"cvv\":\"123\"}'
```

### Test Service Health
```powershell
curl -k https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/payments/health
curl -k https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/actuator/health
```

---

## 🌐 Testing with Browser

### Step 1: Accept Certificates
You need to accept SSL certificates for all routes. Visit each URL and accept:

1. Customer Portal: https://customer-portal-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
2. User Service: https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/actuator/health
3. Payment Service: https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/

For each:
- Click "Advanced"
- Click "Proceed to [domain]" or "Accept Risk and Continue"

### Step 2: Open Browser DevTools
Press `F12` to open DevTools for debugging:
- **Console Tab**: Check for JavaScript errors
- **Network Tab**: Monitor API calls
- **Application Tab**: View localStorage (cart, JWT token)

---

## ✅ Expected Results Checklist

### Customer Portal
- [ ] Page loads without errors
- [ ] Products display in grid
- [ ] Login/Register works
- [ ] Add to cart updates counter
- [ ] Cart shows correct items and totals
- [ ] **Checkout modal shows order summary**
- [ ] **Shipping address form is present**
- [ ] **Payment method selection (Card/COD) is visible**
- [ ] **Card payment opens payment modal**
- [ ] **COD completes without payment modal**
- [ ] Payment succeeds with test card 4111111111111111
- [ ] Payment fails with test card 4000000000000002
- [ ] Cart clears after successful payment

### User Service
- [ ] Health check returns UP
- [ ] Registration creates new user
- [ ] Login returns JWT token
- [ ] Token is valid for API calls

### Payment Service
- [ ] Root endpoint returns service info (NO Whitelabel error)
- [ ] Health check returns UP
- [ ] Test cards endpoint returns card list
- [ ] Payment processing accepts valid requests
- [ ] Test card 4111111111111111 succeeds
- [ ] Test card 4000000000000002 fails

### Admin Dashboard
- [ ] Page loads
- [ ] Login form is present
- [ ] Dashboard is accessible

---

## 🚨 Troubleshooting

### Issue: Whitelabel Error Page
**Solution**: Clear browser cache (Ctrl+Shift+R) and accept certificates

### Issue: Network Error or CORS
**Solution**: Accept certificate for that specific route in a new tab

### Issue: Checkout Modal Doesn't Show
**Solution**: Check browser console for errors, refresh page

### Issue: Payment Processing Stuck
**Solution**: Check payment service logs:
```powershell
oc logs deployment/payment-service -n dry-fruits-platform --tail=50
```

### Issue: Cart Not Updating
**Solution**: Check browser localStorage (F12 → Application → Local Storage)

---

## 📊 Verification Commands

### Check All Pods
```powershell
oc get pods -n dry-fruits-platform
```

### Check All Routes
```powershell
oc get routes -n dry-fruits-platform
```

### Check Service Logs
```powershell
# Customer Portal
oc logs deployment/customer-portal -n dry-fruits-platform --tail=30

# User Service
oc logs deployment/user-service -n dry-fruits-platform --tail=30

# Payment Service
oc logs deployment/payment-service -n dry-fruits-platform --tail=30
```

---

## 🎯 Quick Test URLs (Copy & Paste)

### Just Test Basic Connectivity
```
Customer Portal: https://customer-portal-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
Payment Service Health: https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/payments/health
User Service Health: https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/actuator/health
```

---

## 🆕 What's New in This Update

### ✨ Enhanced Checkout Flow
1. **Order Summary**: See all items before payment
2. **Shipping Address Form**: Enter delivery details
3. **Payment Method Selection**: Choose Card or Cash on Delivery
4. **Better UX**: Step-by-step checkout process

### 💰 Cash on Delivery (COD) Support
- Select COD to skip card payment
- Order placed immediately
- Pay when you receive the items

### 🎯 Improved Payment Flow
- Shipping address captured before payment
- Payment includes shipping details
- Success message shows shipping location

---

**Last Updated**: December 18, 2025  
**Build Version**: customer-portal-build-6  
**Payment Service**: payment-service-build-8  
**Status**: ✅ All services running and tested
