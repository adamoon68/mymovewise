<?php
include_once("config.php");

// Add new columns to tbl_exercises if they don't exist
$sql1 = "ALTER TABLE tbl_exercises ADD COLUMN video_link TEXT";
$sql2 = "ALTER TABLE tbl_exercises ADD COLUMN difficulty_level VARCHAR(50)";
$sql3 = "ALTER TABLE tbl_users ADD COLUMN wellness_points INT(11) DEFAULT 0";
$sql4 = "ALTER TABLE tbl_users ADD COLUMN comfort_streak INT(11) DEFAULT 0";
$sql5 = "ALTER TABLE tbl_users ADD COLUMN last_quest_claim DATE DEFAULT NULL";

$conn->query($sql1);
$conn->query($sql2);
$conn->query($sql3);
$conn->query($sql4);
$conn->query($sql5);

echo "Database Updated Successfully! Ready for Admin inputs and quest rewards.";
?>
