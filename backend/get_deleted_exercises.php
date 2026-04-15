<?php
include_once("config.php");

$createTable = "CREATE TABLE IF NOT EXISTS tbl_deleted_exercises (
    deleted_id INT(11) NOT NULL AUTO_INCREMENT,
    exercise_name VARCHAR(255) NOT NULL UNIQUE,
    deleted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (deleted_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci";
$conn->query($createTable);

$result = $conn->query("SELECT exercise_name FROM tbl_deleted_exercises ORDER BY exercise_name ASC");
$deletedNames = array();

if ($result) {
    while ($row = $result->fetch_assoc()) {
        $deletedNames[] = $row['exercise_name'];
    }
}

sendJsonResponse(array('status' => 'success', 'data' => $deletedNames));

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
