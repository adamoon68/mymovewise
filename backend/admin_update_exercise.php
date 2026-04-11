<?php
if (!isset($_POST)) {
    echo json_encode(array('status' => 'failed', 'data' => null));
    die();
}

include_once("config.php");

$name = $_POST['name'];
$description = $_POST['description'];
$video_link = $_POST['video_link'];
$difficulty = $_POST['difficulty'];
$type = $_POST['type']; // Kept as backup info

// 1. Check if this exercise already exists in the DB (The "Patch" check)
$sqlCheck = "SELECT * FROM tbl_exercises WHERE name = '$name'";
$result = $conn->query($sqlCheck);

if ($result->num_rows > 0) {
    // 2a. UPDATE existing entry
    // Using prepared statements to handle special characters (like quotes) safely
    $stmt = $conn->prepare("UPDATE tbl_exercises SET description=?, video_link=?, difficulty_level=? WHERE name=?");
    $stmt->bind_param("ssss", $description, $video_link, $difficulty, $name);
    
    if ($stmt->execute()) {
        echo json_encode(array('status' => 'success'));
    } else {
        echo json_encode(array('status' => 'failed', 'error' => $stmt->error));
    }

} else {
    // 2b. INSERT new entry (First time this exercise is being edited)
    $stmt = $conn->prepare("INSERT INTO tbl_exercises (name, description, video_link, difficulty_level, type, tags) VALUES (?, ?, ?, ?, ?, 'Edited from CSV')");
    $stmt->bind_param("sssss", $name, $description, $video_link, $difficulty, $type);
    
    if ($stmt->execute()) {
        echo json_encode(array('status' => 'success'));
    } else {
        echo json_encode(array('status' => 'failed', 'error' => $stmt->error));
    }
}
?>