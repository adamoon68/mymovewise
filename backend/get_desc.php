<?php
include_once("config.php");

$name = $_GET['name'];

// Search by exact name match
// We use prepared statement here too to handle names with apostrophes (e.g., "Farmer's Walk")
$stmt = $conn->prepare("SELECT description, video_link, difficulty_level FROM tbl_exercises WHERE name = ?");
$stmt->bind_param("s", $name);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    echo json_encode(array(
        'status' => 'success', 
        'desc' => $row['description'],
        'video_link' => $row['video_link'],
        'difficulty' => $row['difficulty_level']
    ));
} else {
    // No DB entry found -> App should keep using CSV data
    echo json_encode(array('status' => 'no_data'));
}
?>