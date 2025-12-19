# Payment Service Testing Guide

## ✅ Current Status
- **Service Status**: Running (payment-service-84c65d6d4c-59lbm)
- **Build**: payment-service-build-8 (Complete)
- **All Endpoints**: Working correctly

## 🧪 Test Results

### Internal Tests (From Pod)
```bash
# Root Endpoint
✅ GET http://localhost:8084/
Response: {"service":"Payment Service","description":"Mock Payment Gateway API","version":"1.0.0","status":"UP"}

# Health Endpoint
✅ GET http://localhost:8084/api/v1/payments/health
Response: {"service":"payment-service","status":"UP"}

# Test Cards Endpoint
✅ GET http://localhost:8084/api/v1/payments/test-cards
Response: Lists all test cards with success/failure scenarios
```

### External Tests (Through Route)
```bash
# Root Endpoint
✅ GET https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/
Response: {"service":"Payment Service","description":"Mock Payment Gateway API","version":"1.0.0","status":"UP"}

# Health Endpoint
✅ GET https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/payments/health
Response: {"service":"payment-service","status":"UP"}
```

## 🌐 Browser Testing Instructions

### If You See Whitelabel Error in Browser:

#### Step 1: Clear Browser Cache
**Option A - Hard Refresh:**
- Windows: `Ctrl + Shift + R` or `Ctrl + F5`
- Mac: `Cmd + Shift + R`

**Option B - Clear Cache:**
- Chrome: Settings → Privacy and Security → Clear browsing data
- Edge: Settings → Privacy → Clear browsing data
- Select "Cached images and files"
- Time range: "Last hour"

#### Step 2: Accept Certificate Warning
When you visit the URL, you'll see a security warning because of the self-signed certificate:

1. Click "Advanced" or "Show Details"
2. Click "Proceed to [domain]" or "Accept Risk and Continue"

#### Step 3: Test URLs

**Root Endpoint (Service Info):**
```
https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/
```
Expected: JSON with service information
```json
{
  "service": "Payment Service",
  "description": "Mock Payment Gateway API",
  "version": "1.0.0",
  "status": "UP"
}
```

**Health Check:**
```
https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/payments/health
```
Expected:
```json
{
  "service": "payment-service",
  "status": "UP"
}
```

**Test Cards Info:**
```
https://payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com/api/v1/payments/test-cards
```
Expected: List of test cards with their scenarios

## 💳 End-to-End Payment Test

### Step 1: Open Customer Portal
```
https://customer-portal-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
```

### Step 2: Login or Register
- Use existing account or create new one
- Accept certificate warning if prompted

### Step 3: Add Items to Cart
- Browse products
- Click "Add to Cart" for items

### Step 4: Proceed to Checkout
- Click "Proceed to Checkout"
- Accept certificate for payment-service-route if prompted

### Step 5: Enter Payment Details

**For SUCCESS - Use this test card:**
- Card Number: `4111111111111111`
- Card Name: `Test User`
- Expiry Date: `12/27`
- CVV: `123`

**For FAILURE - Use this test card:**
- Card Number: `4000000000000002`
- Card Name: `Test User`
- Expiry Date: `12/27`
- CVV: `123`

### Step 6: Process Payment
- Click "Pay Now"
- Wait for response (~1-2 seconds)

**Expected Success Response:**
```
Payment successful!
Transaction ID: TXN-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

**Expected Failure Response:**
```
Payment failed: Insufficient funds
```

## 🔧 Troubleshooting

### Issue: "Whitelabel Error Page" in Browser

**Cause**: Browser cache or certificate not accepted

**Solutions:**
1. ✅ **Hard refresh** the page (Ctrl+Shift+R)
2. ✅ **Clear browser cache** for the last hour
3. ✅ **Accept certificate** warning when prompted
4. ✅ **Try incognito/private mode** (requires accepting certificate again)
5. ✅ **Close all browser tabs** for the site and reopen

### Issue: "Your connection is not private" or "SSL Error"

**Cause**: Self-signed certificate

**Solution**: 
1. Click "Advanced"
2. Click "Proceed to [domain]" or "Accept Risk"
3. You need to do this for EACH route domain:
   - customer-portal-route-...
   - user-service-route-...
   - payment-service-route-...

### Issue: Network Error or CORS Error

**Cause**: Certificate not accepted for payment-service-route

**Solution**:
1. Open payment service URL directly in new tab
2. Accept certificate warning
3. Return to customer portal and try again

## 📊 Verification Commands

### Check Service Status
```powershell
oc get pods -l app=payment-service -n dry-fruits-platform
```

### Check Service Logs
```powershell
oc logs deployment/payment-service -n dry-fruits-platform --tail=50
```

### Test Endpoint Internally
```powershell
oc exec deployment/payment-service -n dry-fruits-platform -- curl -s http://localhost:8084/
```

### Check Route
```powershell
oc get route payment-service-route -n dry-fruits-platform
```

## ✅ Confirmation Checklist

- [ ] Service pod is running (1/1 Ready)
- [ ] Build 8 completed successfully
- [ ] Root endpoint returns service info (not Whitelabel)
- [ ] Health endpoint returns {"status":"UP"}
- [ ] Browser cache cleared
- [ ] Certificate accepted for payment-service-route
- [ ] Customer portal loads successfully
- [ ] Test payment with 4111111111111111 succeeds
- [ ] Test payment with 4000000000000002 fails as expected

## 🎯 Current Deployment Info

- **Namespace**: dry-fruits-platform
- **Pod**: payment-service-84c65d6d4c-59lbm (Running)
- **Build**: payment-service-build-8 (Complete - Build ID: ce8f430)
- **Service**: payment-service (ClusterIP 172.30.76.169:8084)
- **Route**: payment-service-route-dry-fruits-platform.apps.lab02.ocp4.wfocplab.wwtatc.com
- **Image**: image-registry.openshift-image-registry.svc:5000/dry-fruits-platform/payment-service:latest

## 📞 Support

If you still see Whitelabel error after:
1. ✅ Clearing browser cache
2. ✅ Hard refresh (Ctrl+Shift+R)
3. ✅ Accepting certificate
4. ✅ Testing in incognito mode

Then provide:
- Screenshot of the error
- Browser console output (F12 → Console tab)
- Network tab output (F12 → Network tab)
- Which URL shows the error

---

**Last Updated**: December 18, 2025
**Service Version**: 1.0.0
**Status**: ✅ All endpoints working correctly
