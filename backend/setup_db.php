<?php
include_once("config.php");

// 1. Add 'video_link' column if it doesn't exist
$conn->query("ALTER TABLE tbl_exercises ADD COLUMN video_link TEXT");

// 2. Add 'difficulty_level' column if it doesn't exist
$conn->query("ALTER TABLE tbl_exercises ADD COLUMN difficulty_level VARCHAR(50)");

// 3. Ensure 'name' is indexed for fast lookups (since we use it as the key)
$conn->query("ALTER TABLE tbl_exercises ADD INDEX (name)");

echo "Database successfully upgraded! Ready for Admin edits.";
?>