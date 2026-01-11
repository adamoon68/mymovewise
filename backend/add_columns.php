<?php
include_once("config.php");

// Add new columns to tbl_exercises if they don't exist
$sql1 = "ALTER TABLE tbl_exercises ADD COLUMN video_link TEXT";
$sql2 = "ALTER TABLE tbl_exercises ADD COLUMN difficulty_level VARCHAR(50)";

$conn->query($sql1);
$conn->query($sql2);

echo "Database Updated Successfully! Ready for Admin inputs.";
?>