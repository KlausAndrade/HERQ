# SQL Migration Files

This directory contains all SQL migration and setup files for the HERQ application.

## 📁 File Organization

### 🔧 User Isolation Migrations
- `supabase_user_isolation_migration_clean.sql` - **Main migration script** for user data isolation
- `supabase_verify_user_isolation.sql` - Verification script to check isolation setup
- `supabase_test_user_isolation.sql` - Testing script for user isolation
- `supabase_verify_migration_success.sql` - Verification script for migration success

### 🏗️ Database Schema Files
- `supabase_web_schema.sql` - Main web database schema
- `supabase_leaderboard_schema.sql` - Leaderboard system schema
- `supabase_storage_policies.sql` - Storage access policies
- `supabase_storage_simple.sql` - Simplified storage setup

### 🔄 Migration Files
- `supabase_exercise_types_migration.sql` - Exercise types migration
- `supabase_variant_migration.sql` - Exercise variant migration
- `supabase_update_exercise_types.sql` - Exercise types update
- `supabase_add_sort_order.sql` - Sort order functionality
- `supabase_migration_privacy.sql` - Privacy settings migration
- `supabase_posts_rls_fix.sql` - Posts RLS policy fixes

### 🔍 Verification Files
- `supabase_schema_verification.sql` - General schema verification

## 🚀 Usage

### Setting Up User Isolation
1. Run `supabase_verify_user_isolation.sql` to check current state
2. Run `supabase_user_isolation_migration_clean.sql` for the main migration
3. Run `supabase_test_user_isolation.sql` to test the setup
4. Run `supabase_verify_migration_success.sql` to verify success

### Database Setup
1. Run `supabase_web_schema.sql` for the main schema
2. Run other migration files as needed for specific features
3. Use verification files to check setup status

## ⚠️ Important Notes

- **Always backup your database** before running migrations
- **Test migrations in a development environment** first
- **Run verification scripts** after migrations to ensure success
- **Check the main README** for complete setup instructions

## 📚 Related Documentation

- See `../guides/USER_ISOLATION_SETUP_GUIDE.md` for detailed setup instructions
- See `../guides/USER_ISOLATION_TESTING_GUIDE.md` for testing procedures
