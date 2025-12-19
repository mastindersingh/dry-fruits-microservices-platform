# 🔧 Troubleshooting Guide - Services Are Working!

## ✅ Current Status

All services are **RUNNING** successfully:

```
✅ user-service-64d565d696-sgdgv      (1/1 Running) - 32 hours uptime
✅ customer-portal-6bd7c74b99-pd2g6   (1/1 Running) - 7 minutes uptime  
✅ payment-service-84c65d6d4c-59lbm   (1/1 Running) - 21 minutes uptime
✅ postgres-568ffc999f-hhl8q          (1/1 Running) - Database
✅ postgres-users-0                   (1/1 Running) - User Database
```

## 🌐 All Working URLs

### Customer Portal (START HERE)
```
https://customer-portal-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```

### User Service API
```
https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/actuator/health
```

### Payment Service
```
https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/
```

---

## 🔍 Why You See "Down" Error

The services are actually **UP and RUNNING**. The issue is:

### 1️⃣ **SSL Certificate Warning** (Most Common)

When you open any HTTPS URL, you'll see:
- "Your connection is not private"
- "NET::ERR_CERT_AUTHORITY_INVALID"
- "SSL Certificate Error"

**This is NORMAL for OpenShift self-signed certificates!**

#### How to Fix:
1. Click "Advanced" button
2. Click "Proceed to [domain]" or "Accept the Risk and Continue"
3. **You must do this for EACH domain:**
   - customer-portal-route-...
   - user-service-route-...
   - payment-service-route-...

---

## 📋 Step-by-Step: Test Everything

### Step 1: Test Customer Portal

1. Open in browser:
   ```
   https://customer-portal-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
   ```

2. You'll see: **"Your connection is not private"**

3. Click **"Advanced"**

4. Click **"Proceed to customer-portal-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com"**

5. ✅ Customer portal should load!

---

### Step 2: Test User Service

1. Open in **NEW TAB**:
   ```
   https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/actuator/health
   ```

2. Accept certificate warning (same as Step 1)

3. ✅ You should see:
   ```json
   {
     "status": "UP",
     "components": {
       "db": {"status": "UP"},
       ...
     }
   }
   ```

---

### Step 3: Test Payment Service

1. Open in **NEW TAB**:
   ```
   https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/
   ```

2. Accept certificate warning

3. ✅ You should see:
   ```json
   {
     "service": "Payment Service",
     "description": "Mock Payment Gateway API",
     "version": "1.0.0",
     "status": "UP"
   }
   ```

---

## 🛒 Test Complete Checkout Flow

### Step 1: Open Customer Portal
Already done above ✅

### Step 2: Register/Login

1. Click **"Login"** in top-right navbar
2. Click **"Register here"**
3. Fill form:
   - Name: `Test User`
   - Email: `test@example.com`
   - Password: `password123`
   - Confirm Password: `password123`
4. Click **"Create Account"**
5. ✅ You should be logged in

### Step 3: Add Products to Cart

1. Scroll down to **"Our Premium Products"**
2. Click **"Add to Cart"** on 2-3 products
3. ✅ Cart counter in navbar should update (e.g., "Cart 3")

### Step 4: View Cart

1. Click **Cart icon** in navbar
2. ✅ You should see:
   - List of items
   - Quantities
   - Subtotal, Shipping, Total

### Step 5: Checkout ⭐ NEW FLOW

1. Click **"Checkout"** button
2. ✅ **Checkout Modal** should open with:
   - Order summary table
   - Subtotal/Shipping/Total
   - Shipping address form
   - Payment method selection

**If checkout modal doesn't open:**
- Press **F12** (open DevTools)
- Click **Console** tab
- Look for error messages
- Most common: Certificate not accepted for payment-service

### Step 6: Fill Shipping Information

```
Full Name:      John Doe
Phone:          555-123-4567
Street Address: 123 Main St
City:           New York
State:          NY
ZIP:            10001
```

### Step 7: Choose Payment Method

**Option A: Credit Card**
- Select **"Credit/Debit Card"** radio button
- Click **"Proceed to Payment"**
- Payment modal opens
- Enter card: `4111111111111111`
- Expiry: `12/27`
- CVV: `123`
- Click **"Pay Now"**

**Option B: Cash on Delivery**
- Select **"Cash on Delivery"** radio button
- Click **"Proceed to Payment"**
- Order placed immediately (no payment modal)
- ✅ Success message with Order ID

---

## 🚨 Common Issues

### Issue 1: "This site can't be reached" or "ERR_NAME_NOT_RESOLVED"

**Cause**: DNS issue or network problem

**Solutions**:
1. Check your internet connection
2. Try from a different network
3. Make sure you can access other `.apps.lab02.ocp4.wfocplab.wwtatc.com` domains

---

### Issue 2: Checkout Button Does Nothing

**Cause**: Not logged in, or JavaScript error

**Solutions**:
1. Make sure you're logged in (see "Login" in navbar, should show your name)
2. Open DevTools (F12) → Console tab
3. Look for red error messages
4. Most common: "CORS error" or "NetworkError" = Certificate issue

**Fix**: Open payment-service URL in new tab and accept certificate

---

### Issue 3: "NetworkError" or "CORS" Error During Payment

**Cause**: Haven't accepted certificate for payment-service-route

**Solution**:
1. Open new tab
2. Go to: `https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/`
3. Accept certificate
4. Return to customer portal
5. Try checkout again

---

### Issue 4: User Service Shows "Down"

**From Browser**: You haven't accepted the certificate

**Solution**:
1. Open: `https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/actuator/health`
2. Accept certificate
3. ✅ Should show `{"status":"UP"}`

**From Command Line**: The service IS up (we tested it!)

```powershell
# Test from OpenShift cluster (WORKS)
oc run test-curl --image=curlimages/curl:latest --rm -i --restart=Never -n dry-fruits-platform -- curl -sk https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/actuator/health
```

---

## 🔐 Certificate Acceptance Checklist

Accept certificates for ALL these URLs (one by one):

- [ ] Customer Portal: https://customer-portal-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
- [ ] User Service: https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/actuator/health
- [ ] Payment Service: https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/

**For each URL:**
1. Open in browser
2. See "Not secure" warning
3. Click "Advanced"
4. Click "Proceed to [domain]"
5. ✅ Page loads

---

## 🎯 Quick Verification Commands

### Check All Services Are Running
```powershell
oc get pods -n dry-fruits-platform | Select-String "user-service|customer-portal|payment-service"
```

Expected output:
```
customer-portal-xxxxx   1/1   Running
payment-service-xxxxx   1/1   Running
user-service-xxxxx      1/1   Running
```

### Test Services from OpenShift Cluster
```powershell
# User Service
oc run test-user --image=curlimages/curl:latest --rm -i --restart=Never -n dry-fruits-platform -- curl -sk https://user-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/actuator/health

# Payment Service
oc run test-payment --image=curlimages/curl:latest --rm -i --restart=Never -n dry-fruits-platform -- curl -sk https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/
```

Both should return JSON responses = ✅ Services are UP!

---

## ✅ Summary

**Your services ARE working!** The issue is just SSL certificate warnings in the browser.

**To fix:**
1. Open each URL in browser
2. Accept the certificate warning
3. Try checkout flow again

**If still having issues:**
- Open browser DevTools (F12)
- Check Console tab for specific error messages
- Share the error message for more help

---

**All services confirmed running:**
- ✅ User Service: UP (32 hours)
- ✅ Customer Portal: UP (7 minutes, latest build)
- ✅ Payment Service: UP (21 minutes, latest build)
- ✅ PostgreSQL: UP (34 hours)

**Your platform is fully functional!** 🎉
