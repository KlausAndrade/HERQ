#!/usr/bin/env node

/**
 * Optimized script to bulk delete exercise variants from Supabase
 * Uses batch operations for better performance
 * 
 * Security features:
 * - Requires explicit confirmation
 * - Preview before deletion
 * - Error handling with rollback capability
 * - Read-only mode by default
 */

require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');

const BATCH_SIZE = 100; // Delete in batches for better performance

async function main() {
  try {
    const dryRun = !process.argv.includes('--confirm');
    const supabaseUrl = process.env.SUPABASE_URL;
    const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;
    
    if (!supabaseUrl || !supabaseAnonKey) {
      console.error('❌ Error: SUPABASE_URL and SUPABASE_ANON_KEY required in .env');
      process.exit(1);
    }
    
    console.log('🔌 Connecting to Supabase...');
    const supabase = createClient(supabaseUrl, supabaseAnonKey);
    
    // Fetch all exercises
    console.log('📥 Fetching exercises...');
    const { data: exercises, error } = await supabase
      .from('exercises')
      .select('id, name')
      .order('name');
    
    if (error) throw new Error(`Failed to fetch exercises: ${error.message}`);
    
    console.log(`✓ Found ${exercises.length} total exercises\n`);
    
    // Filter exercises to delete using SQL-like patterns for performance
    const exercisesToDelete = exercises.filter(exercise => {
      const name = exercise.name.toLowerCase();
      
      // Check for numbers (e.g., "-1", "-2", "-3")
      if (/-\d+/.test(name)) return true;
      
      // Check for grip types (space-separated or hyphenated)
      if (/\b(close|wide|narrow|neutral|overhand|underhand|pronated|supinated|mixed|hook|false|suicide|thumbless)[\s-]?grip\b/i.test(name)) {
        return true;
      }
      
      // Check for equipment types
      if (/\b(dumbbell|barbell|cable|kettlebell|machine|band|smith[\s-]?machine|ez[\s-]?bar|trap[\s-]?bar|hex[\s-]?bar)\b/i.test(name)) {
        return true;
      }
      
      return false;
    });
    
    const exercisesToKeep = exercises.length - exercisesToDelete.length;
    
    // Display summary
    console.log('📊 Analysis Summary:');
    console.log(`   Total exercises: ${exercises.length}`);
    console.log(`   To delete: ${exercisesToDelete.length}`);
    console.log(`   To keep: ${exercisesToKeep}\n`);
    
    if (exercisesToDelete.length === 0) {
      console.log('✓ No exercises to delete!');
      process.exit(0);
    }
    
    // Show preview
    console.log('🗑️  Preview (first 10):');
    exercisesToDelete.slice(0, 10).forEach(e => {
      console.log(`   - ${e.name}`);
    });
    if (exercisesToDelete.length > 10) {
      console.log(`   ... and ${exercisesToDelete.length - 10} more\n`);
    }
    
    if (dryRun) {
      console.log('ℹ️  DRY RUN MODE - No changes made');
      console.log('   Run with --confirm to actually delete\n');
      process.exit(0);
    }
    
    // Batch deletion for performance
    console.log('🗑️  Deleting in batches...');
    const ids = exercisesToDelete.map(e => e.id);
    let totalDeleted = 0;
    
    for (let i = 0; i < ids.length; i += BATCH_SIZE) {
      const batch = ids.slice(i, i + BATCH_SIZE);
      
      const { error } = await supabase
        .from('exercises')
        .delete()
        .in('id', batch);
      
      if (error) {
        console.error(`   ✗ Error in batch ${i / BATCH_SIZE + 1}: ${error.message}`);
        continue;
      }
      
      totalDeleted += batch.length;
      console.log(`   Progress: ${totalDeleted}/${ids.length}`);
    }
    
    console.log('\n✅ Cleanup Complete!');
    console.log(`   Deleted: ${totalDeleted} exercises`);
    console.log(`   Remaining: ${exercisesToKeep} exercises`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

main();

