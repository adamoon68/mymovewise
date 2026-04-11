<?php
include_once("config.php");

$name = $_POST['name'];
$description = $_POST['description'];
$type = $_POST['type']; // Backup info just in case we need to create the row

// Check if exercise already exists in DB
$check = $conn->query("SELECT * FROM tbl_exercises WHERE name = '$name'");

if ($check->num_rows > 0) {
    // UPDATE existing entry
    // We use prepared statements to handle special characters (like quotes in text)
    $stmt = $conn->prepare("UPDATE tbl_exercises SET description = ? WHERE name = ?");
    $stmt->bind_param("ss", $description, $name);
    
    if ($stmt->execute()) {
        echo json_encode(array('status' => 'success'));
    } else {
        echo json_encode(array('status' => 'failed', 'error' => $conn->error));
    }
} else {
    // INSERT new entry (Creating the "Patch")
    $stmt = $conn->prepare("INSERT INTO tbl_exercises (name, description, type, tags) VALUES (?, ?, ?, 'Patch Data')");
    $stmt->bind_param("sss", $name, $description, $type);
    
    if ($stmt->execute()) {
        echo json_encode(array('status' => 'success'));
    } else {
        echo json_encode(array('status' => 'failed', 'error' => $conn->error));
    }
}
?>