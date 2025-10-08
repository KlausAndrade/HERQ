# Groq AI Setup Guide

## Quick Start (5 minutes)

### Step 1: Get Your Free Groq API Key

1. **Visit Groq Console**
   - Go to: https://console.groq.com
   - Click "Sign Up" (or "Log In" if you have an account)

2. **Create Account**
   - Sign up with Google, GitHub, or email
   - Free tier available - no credit card required!

3. **Generate API Key**
   - Navigate to "API Keys" in the left sidebar
   - Click "Create API Key"
   - Give it a name (e.g., "GymAI Development")
   - Click "Create"
   - **IMPORTANT**: Copy the key immediately - you won't see it again!

### Step 2: Configure Your App

1. **Create Environment File**
   ```bash
   cd /Users/klausandrade/Projects/Mobile/GymAI
   cp .env.example .env
   ```

2. **Add Your API Key**
   Edit `.env` and replace the placeholder:
   ```bash
   # Before
   GROQ_API_KEY=your_groq_api_key_here
   
   # After (use your actual key)
   GROQ_API_KEY=gsk_1234567890abcdefghijklmnopqrstuvwxyz
   ```

3. **Enable AI Coaching**
   Ensure this is set in your `.env`:
   ```bash
   ENABLE_AI_COACHING=true
   ```

### Step 3: Verify Integration

1. **Clean Build**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Run the App**
   ```bash
   flutter run
   ```

3. **Test AI Features**
   - Navigate to AI Coaching screen
   - Request workout recommendations
   - Check for "Powered by Groq AI" indicator
   - Verify responses are personalized (not mock data)

---

## Free Tier Limits

Groq's free tier is very generous:

| Feature | Free Tier | Notes |
|---------|-----------|-------|
| **Requests/day** | 14,400 | ~10 req/min |
| **Tokens/min** | 6,000 | Plenty for our use case |
| **Models** | All models | Including Llama 3.3 70B |
| **Speed** | Ultra-fast | 200-500ms avg |
| **Cost** | $0.00 | Completely free! |

**Typical GymAI Usage:**
- Workout recommendation: ~1,000 tokens
- Recovery analysis: ~500 tokens  
- Exercise substitution: ~200 tokens
- **Estimated daily limit**: ~100-200 AI requests (more than enough!)

---

## Troubleshooting

### ❌ Error: "GROQ_API_KEY not found in .env"

**Solution:**
1. Ensure `.env` file exists in project root
2. Verify key is on correct line: `GROQ_API_KEY=gsk_...`
3. No spaces around `=` sign
4. Restart Flutter app after editing `.env`

### ❌ Error: "Invalid API key"

**Solution:**
1. Check key was copied correctly (no extra spaces)
2. Ensure key starts with `gsk_`
3. Generate new key if compromised
4. Verify Groq account is active

### ❌ Error: "Rate limit exceeded"

**Solution:**
1. App automatically falls back to mock service
2. Wait 1 minute for rate limit reset
3. For production, consider caching responses
4. Upgrade to paid tier if needed ($0.27/M tokens)

### ❌ AI responses are still mock data

**Solution:**
1. Check `.env` has `ENABLE_AI_COACHING=true`
2. Verify Groq API key is valid
3. Check console for error messages
4. Ensure internet connection is active
5. Try force-stopping and restarting app

### ❌ Slow responses (>3 seconds)

**Solution:**
1. Check internet connection speed
2. Groq is usually <500ms, delays indicate network issues
3. Try different network (WiFi vs cellular)
4. Check Groq status: https://status.groq.com

---

## Development vs Production

### Development Setup
```bash
# .env.development
GROQ_API_KEY=gsk_dev_key_here
ENABLE_AI_COACHING=true
```

### Production Setup
```bash
# .env.production
GROQ_API_KEY=gsk_prod_key_here
ENABLE_AI_COACHING=true
```

**Best Practices:**
- ✅ Use separate keys for dev/staging/prod
- ✅ Rotate keys every 90 days
- ✅ Never commit `.env` to Git (already in `.gitignore`)
- ✅ Store prod keys in secure vault (1Password, AWS Secrets Manager)
- ✅ Monitor usage in Groq console

---

## Testing Without API Key

If you don't have a Groq API key yet:

1. **Mock Service Fallback**
   - App automatically uses mock AI if key missing
   - All features work with synthetic data
   - Great for UI development/testing

2. **Get Key Later**
   - Features work immediately with mock
   - Add real AI when ready
   - Zero code changes needed

3. **Disable AI Temporarily**
   ```bash
   # In .env
   ENABLE_AI_COACHING=false
   ```

---

## Advanced Configuration

### Custom Model Selection

Edit `lib/src/core/services/groq_service.dart`:

```dart
class GroqService {
  GroqService({
    String? apiKey,
    String model = 'llama-3.3-70b-versatile', // Change here
  }) : _groq = Groq(
```

**Available Models:**
- `llama-3.3-70b-versatile` (default) - Best quality, fastest
- `llama-3.1-8b-instant` - Faster, lower quality
- `mixtral-8x7b-32768` - Long context window
- `gemma2-9b-it` - Efficient, good quality

### Response Timeout

Edit individual service methods:

```dart
final response = await _groqService.chat(
  prompt: prompt,
  systemPrompt: systemPrompt,
  timeout: Duration(seconds: 10), // Add timeout
);
```

### Rate Limit Handling

Implement exponential backoff:

```dart
int retries = 0;
while (retries < 3) {
  try {
    return await _groqService.chat(...);
  } on GroqException catch (e) {
    if (e.message.contains('rate limit')) {
      await Future.delayed(Duration(seconds: 2 ^ retries));
      retries++;
    } else {
      rethrow;
    }
  }
}
```

---

## Security Best Practices

### ✅ DO:
- Store API key in `.env` file
- Add `.env` to `.gitignore`
- Use environment-specific keys
- Rotate keys regularly
- Monitor usage in console
- Implement rate limiting
- Log errors (not keys!)

### ❌ DON'T:
- Commit API keys to Git
- Share keys in screenshots
- Hardcode keys in source
- Use same key everywhere
- Expose keys in logs
- Store in client-side only apps (web)
- Ignore rate limits

### Web App Security
For web builds, consider:
- Backend proxy for API calls
- Server-side key storage
- CORS restrictions
- Request signing

---

## Monitoring & Optimization

### Check Usage
1. Visit: https://console.groq.com/usage
2. View requests/day
3. Monitor token consumption
4. Track response times
5. Check error rates

### Optimize Costs
- **Cache responses**: Use Riverpod auto-dispose
- **Limit context**: Only last 10 workouts, not all
- **Compress prompts**: Remove unnecessary words
- **Batch requests**: Combine related queries
- **Smart fallback**: Use mock for non-critical features

### Performance Metrics
Monitor in app:
```dart
final start = DateTime.now();
final result = await groqService.chat(...);
final duration = DateTime.now().difference(start);
print('Groq response time: ${duration.inMilliseconds}ms');
```

Expected metrics:
- p50: 200-300ms
- p95: 400-600ms
- p99: 800-1200ms

---

## Support Resources

### Groq Documentation
- **API Docs**: https://console.groq.com/docs
- **Models**: https://console.groq.com/docs/models
- **Rate Limits**: https://console.groq.com/docs/rate-limits
- **Status Page**: https://status.groq.com

### GymAI Documentation
- **Integration Guide**: `GROQ_INTEGRATION.md`
- **Architecture**: `.github/copilot-instructions.md`
- **Testing**: `TESTING_CHECKLIST.md`

### Get Help
- Groq Discord: https://groq.com/discord
- GitHub Issues: [GymAI repo]
- Email: [your support email]

---

## Next Steps

Once Groq is working:

1. **✨ Try Advanced Features**
   - Recovery analysis with real data
   - Progressive overload AI suggestions
   - Exercise substitutions for injuries

2. **📊 Monitor Performance**
   - Check response times
   - Track API usage
   - Optimize prompts

3. **🚀 Enhance AI**
   - Add conversation memory
   - Implement few-shot learning
   - Custom training examples

4. **🔒 Production Hardening**
   - Backend API proxy
   - Rate limit middleware
   - Error monitoring (Sentry)
   - Usage analytics

---

## FAQ

**Q: Is Groq free forever?**
A: Free tier has generous limits (14,400 req/day). Paid plans available for scale.

**Q: How fast is Groq really?**
A: 10-100x faster than typical LLMs. Expect 200-500ms responses.

**Q: What if Groq goes down?**
A: App automatically falls back to mock service. Zero downtime.

**Q: Can I use OpenAI instead?**
A: Yes, create similar service for OpenAI. Groq is faster + cheaper though.

**Q: Does it work offline?**
A: Mock service works offline. Groq requires internet for AI.

**Q: How private is my data?**
A: Only exercise names sent to Groq. No personal info, no workout notes.

**Q: Can I self-host the model?**
A: Groq uses custom LPU hardware. Use Ollama for local models instead.

**Q: What happens if I exceed rate limits?**
A: App falls back to mock service automatically. Transparent to users.

---

## Success Checklist

Before considering Groq integration complete:

- [ ] API key obtained from console.groq.com
- [ ] `.env` file created with valid key
- [ ] `ENABLE_AI_COACHING=true` in `.env`
- [ ] App runs without errors
- [ ] AI Coaching screen shows real recommendations
- [ ] Response time < 1 second
- [ ] Fallback to mock works (test with invalid key)
- [ ] No API key in Git commits
- [ ] Usage monitored in Groq console
- [ ] Documentation updated for team

---

**🎉 Congratulations! You now have ultra-fast AI coaching in your app!**

Groq's lightning-fast inference means your users get instant, personalized workout recommendations powered by state-of-the-art LLMs. The fallback system ensures the app works perfectly even without an API key.

*For more details, see `GROQ_INTEGRATION.md`*
