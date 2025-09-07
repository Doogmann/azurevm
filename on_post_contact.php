<?php
// Handle POST request for contact form submission
require_once 'database_setup.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name = $_POST['name'] ?? '';
    $email = $_POST['email'] ?? '';
    $message = $_POST['message'] ?? '';

    if (!empty($name) && !empty($email) && !empty($message)) {
        try {
            $stmt = $pdo->prepare("INSERT INTO contacts (name, email, message) VALUES (?, ?, ?)");
            $stmt->execute([$name, $email, $message]);
            $success = true;
        } catch(PDOException $e) {
            $error = "Error saving message: " . $e->getMessage();
        }
    } else {
        $error = "All fields are required.";
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Message Sent - Azure MySQL Contact App</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>📨 Message Status</h1>
        </header>

        <nav>
            <a href="index.html" class="btn">Home</a>
            <a href="contact_form.html" class="btn">Contact Form</a>
            <a href="on_get_messages.php" class="btn">View Messages</a>
        </nav>

        <main>
            <?php if (isset($success)): ?>
                <div class="success-message">
                    <h2>✅ Message Sent Successfully!</h2>
                    <p>Thank you for your message. It has been saved to the Azure MySQL database.</p>
                </div>
            <?php elseif (isset($error)): ?>
                <div class="error-message">
                    <h2>❌ Error</h2>
                    <p><?php echo htmlspecialchars($error); ?></p>
                </div>
            <?php endif; ?>

            <div class="actions">
                <a href="contact_form.html" class="btn">Send Another Message</a>
                <a href="on_get_messages.php" class="btn">View All Messages</a>
            </div>
        </main>
    </div>
</body>
</html>
