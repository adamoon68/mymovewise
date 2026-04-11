<?php
include_once("config.php");

// Retrieve all exercises
$sql = "SELECT * FROM tbl_exercises";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $exercises = array();
    while ($row = $result->fetch_assoc()) {
        $ex = array();
        $ex['id'] = $row['exercise_id'];
        $ex['name'] = $row['name'];
        $ex['description'] = $row['description'];
        $ex['type'] = $row['type'];
        $ex['tags'] = $row['tags']; // Critical: App uses this string to filter "High Impact"
        array_push($exercises, $ex);
    }
    $response = array('status' => 'success', 'data' => $exercises);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>