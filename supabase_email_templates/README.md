# HERQ Supabase Email Templates

Professional email templates for HERQ's Supabase authentication flows, designed with the HERQ brand guidelines in mind.

## 📧 Templates Included

### 1. **Confirm Signup** (`confirm_signup.html`)
- **Purpose**: Welcome new users and confirm their email address
- **Features**: 
  - HERQ branding with gradient header
  - Strength-focused messaging
  - Feature highlights
  - Security notice
- **Variables**: `{{ .ConfirmationURL }}`

### 2. **Invite User** (`invite_user.html`)
- **Purpose**: Invite new users to join HERQ
- **Features**:
  - Inviter information display
  - Feature grid showcasing HERQ benefits
  - Social features emphasis
- **Variables**: `{{ .ConfirmationURL }}`, `{{ .InviterName }}`

### 3. **Magic Link** (`magic_link.html`)
- **Purpose**: Passwordless authentication
- **Features**:
  - Security-focused messaging
  - Benefits of magic links
  - Expiration notice
- **Variables**: `{{ .ConfirmationURL }}`

### 4. **Change Email Address** (`change_email.html`)
- **Purpose**: Confirm email address changes
- **Features**:
  - Old/new email comparison
  - Security explanation
  - Account continuity assurance
- **Variables**: `{{ .ConfirmationURL }}`, `{{ .OldEmail }}`, `{{ .NewEmail }}`

### 5. **Reset Password** (`reset_password.html`)
- **Purpose**: Password reset functionality
- **Features**:
  - Security alert
  - Password strength tips
  - Motivational messaging
- **Variables**: `{{ .ConfirmationURL }}`

### 6. **Re-authentication** (`reauthentication.html`)
- **Purpose**: Confirm identity for sensitive operations
- **Features**:
  - Security explanation
  - Use case examples
  - Trust-building messaging
- **Variables**: `{{ .ConfirmationURL }}`

## 🎨 Design Features

### Brand Consistency
- **Colors**: Electric Teal (#00BFA6), Warm Lime (#D4FF4D), Deep Graphite (#1B1D21)
- **Typography**: Inter for body text, Anton/Monument Extended for headers
- **Gradients**: Teal to Lime gradient for CTAs and headers

### Responsive Design
- Mobile-first approach
- Flexible grid layouts
- Touch-friendly buttons (44px minimum)
- Readable typography scales

### Accessibility
- High contrast ratios (WCAG AA compliant)
- Semantic HTML structure
- Alt text for images
- Keyboard navigation support

## 🚀 Implementation

### Supabase Setup
1. Navigate to your Supabase project dashboard
2. Go to Authentication > Email Templates
3. Replace the default templates with these HTML files
4. Configure the template variables as needed

### Template Variables
Each template uses Supabase's standard template variables:
- `{{ .ConfirmationURL }}` - The confirmation/reset link
- `{{ .InviterName }}` - Name of the person who invited the user
- `{{ .OldEmail }}` - Previous email address
- `{{ .NewEmail }}` - New email address

### Customization
To customize these templates:
1. Edit the HTML files directly
2. Maintain the HERQ brand colors and typography
3. Test across different email clients
4. Ensure mobile responsiveness

## 📱 Email Client Compatibility

Tested and optimized for:
- **Desktop**: Gmail, Outlook, Apple Mail, Thunderbird
- **Mobile**: iOS Mail, Gmail Mobile, Samsung Email
- **Web**: Gmail Web, Outlook Web, Yahoo Mail

## 🔧 Technical Notes

### CSS Support
- Uses modern CSS features with fallbacks
- Inline styles for maximum compatibility
- Media queries for responsive design
- CSS Grid and Flexbox for layouts

### Security Considerations
- No external resources (all styles inline)
- No JavaScript (email security)
- HTTPS-only links
- Expiration notices for time-sensitive actions

## 📊 Performance

### File Sizes
- All templates under 50KB
- Optimized images and minimal external dependencies
- Fast loading across all email clients

### Loading Speed
- Inline CSS for immediate rendering
- Minimal external dependencies
- Optimized HTML structure

## 🎯 Brand Alignment

### Voice & Tone
- **Confident**: Direct, action-oriented language
- **Minimal**: Clean, concise messaging
- **Inclusive**: Welcoming to all fitness levels

### Visual Identity
- **Strength-focused**: Uses fitness and strength metaphors
- **Modern**: Clean, contemporary design
- **Professional**: Trustworthy and reliable appearance

## 📈 Analytics & Tracking

### Recommended Tracking
- Open rates for each template type
- Click-through rates on CTA buttons
- Conversion rates from email to app usage
- A/B testing different subject lines

### Metrics to Monitor
- Email delivery rates
- Template rendering across clients
- User engagement with different templates
- Security-related email effectiveness

## 🔄 Maintenance

### Regular Updates
- Review templates quarterly
- Update brand elements as needed
- Test new email client versions
- Monitor user feedback

### Version Control
- Keep templates in version control
- Document changes and updates
- Test thoroughly before deployment
- Maintain backup copies

## 📞 Support

For questions about these templates or HERQ branding:
- Check the brand guidelines in `/docs/BRAND_GUIDELINES.md`
- Review the main README for app context
- Contact the HERQ team for customization requests

---

**HERQ** - Smart Strength. Simplified. 💪
