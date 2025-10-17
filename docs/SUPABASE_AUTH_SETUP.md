# 🔐 Supabase Authentication Setup Guide

This guide will help you configure Supabase authentication to work properly with your HERQ app.

## 🚨 **Critical Issue: Email Confirmation Not Working**

If users click the confirmation email but nothing happens, you need to configure the redirect URLs in Supabase.

## 📋 **Step-by-Step Setup**

### 1. **Configure Supabase Auth Settings**

Go to your Supabase dashboard → **Authentication** → **Settings**

#### **Site URL**
```
https://your-domain.com
```
*For local development:*
```
http://localhost:3000
```

#### **Redirect URLs** (Add these URLs)
```
https://your-domain.com/auth/callback
http://localhost:3000/auth/callback
```

### 2. **Update Email Templates**

In Supabase dashboard → **Authentication** → **Email Templates**

Replace the default templates with the ones in `/supabase_email_templates/`:

- **Confirm signup** → `confirm_signup.html`
- **Invite user** → `invite_user.html` 
- **Magic link** → `magic_link.html`
- **Change email address** → `change_email.html`
- **Reset password** → `reset_password.html`
- **Re-authentication** → `reauthentication.html`

### 3. **Test the Flow**

1. **Sign up** with a new email
2. **Check email** for confirmation link
3. **Click the link** - should redirect to `/auth/callback`
4. **App should authenticate** and redirect to home page

## 🔧 **Troubleshooting**

### **Problem: Email link does nothing**
- ✅ **Check redirect URLs** in Supabase settings
- ✅ **Verify callback route** exists in your app
- ✅ **Check browser console** for errors

### **Problem: "Invalid authentication link"**
- ✅ **Check Site URL** matches your domain
- ✅ **Verify HTTPS** is enabled (required for production)
- ✅ **Check URL encoding** in email templates

### **Problem: User stays on auth screen**
- ✅ **Check auth state** in browser dev tools
- ✅ **Verify session** is created after callback
- ✅ **Check router redirects** are working

## 🌐 **URL Configuration Examples**

### **Development**
```
Site URL: http://localhost:3000
Redirect URLs: 
  - http://localhost:3000/auth/callback
```

### **Production**
```
Site URL: https://herq.app
Redirect URLs:
  - https://herq.app/auth/callback
```

### **Multiple Environments**
```
Site URL: https://herq.app
Redirect URLs:
  - https://herq.app/auth/callback
  - https://staging.herq.app/auth/callback
  - http://localhost:3000/auth/callback
```

## 📧 **Email Template Variables**

The email templates use these Supabase variables:
- `{{ .ConfirmationURL }}` - The confirmation link
- `{{ .InviterName }}` - Name of person who invited user
- `{{ .OldEmail }}` - Previous email address
- `{{ .NewEmail }}` - New email address

## 🔍 **Debugging Steps**

### **1. Check Supabase Logs**
Go to **Logs** → **Auth** to see authentication events

### **2. Test Callback URL**
Visit: `https://your-domain.com/auth/callback?access_token=test`
Should show the auth callback screen

### **3. Check Browser Network Tab**
Look for failed requests or CORS errors

### **4. Verify Environment Variables**
Make sure `SUPABASE_URL` and `SUPABASE_ANON_KEY` are set correctly

## 🚀 **Deployment Checklist**

- [ ] **Site URL** configured for production domain
- [ ] **Redirect URLs** include production callback URL
- [ ] **HTTPS** enabled (required for production)
- [ ] **Email templates** updated with HERQ branding
- [ ] **CORS** configured for your domain
- [ ] **Environment variables** set in production

## 📱 **Mobile App Configuration**

For mobile apps, you'll also need:

### **Deep Link URLs**
```
herq://auth/callback
```

### **App Store Configuration**
- Configure URL schemes in iOS/Android
- Add deep link handling in your app

## 🆘 **Common Issues**

### **"Redirect URL not allowed"**
- Add the callback URL to Supabase redirect URLs
- Check for typos in the URL

### **"Invalid client"**
- Verify Supabase URL and anon key
- Check environment variables

### **"Session not found"**
- Check if user is already authenticated
- Verify session persistence

### **"CORS error"**
- Configure CORS in Supabase settings
- Add your domain to allowed origins

## 📞 **Need Help?**

1. Check Supabase documentation: https://supabase.com/docs/guides/auth
2. Review your app's auth flow in browser dev tools
3. Test with a simple email confirmation first
4. Verify all URLs are correctly configured

---

**Remember**: The key is having the correct redirect URLs configured in Supabase that match your app's callback route!
