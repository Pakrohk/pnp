import sys
import os
import time
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QTimer, QUrl, QCoreApplication, Qt
from PySide6.QtGui import QGuiApplication, QPixmap

# Mocking some stuff if needed, but let's try to run the real thing
# We need to add src to sys.path
script_dir = os.path.dirname(os.path.abspath(__file__))
src_dir = os.path.join(script_dir, 'src')
sys.path.insert(0, src_dir)

os.environ["QT_QPA_PLATFORM"] = "offscreen"
# Force Kirigami paths for the test if possible, but they might not exist in sandbox
# If they don't exist, it should fallback to StandardMain.qml

from pnp.gui import setup_kde_integration
from pnp.gui.backend import Backend

def main():
    app = QApplication(sys.argv)
    app.setApplicationName("PNP-Verify")

    engine = QQmlApplicationEngine()

    # We don't want to use the real tray in offscreen mode as it might fail
    # We just want the window

    has_kirigami = setup_kde_integration(app, engine)
    print(f"Has Kirigami: {has_kirigami}")

    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)

    if has_kirigami:
        qml_file = os.path.join(src_dir, "pnp", "gui", "qml", "main.qml")
    else:
        qml_file = os.path.join(src_dir, "pnp", "gui", "qml", "StandardMain.qml")

    engine.load(QUrl.fromLocalFile(qml_file))

    if not engine.rootObjects():
        print("Failed to load QML")
        sys.exit(-1)

    window = engine.rootObjects()[0]
    window.show()

    # Give it a moment to render
    QTimer.singleShot(2000, lambda: take_screenshot(window))

    # Exit after 3 seconds
    QTimer.singleShot(3000, app.quit)

    sys.exit(app.exec())

def take_screenshot(window):
    print("Taking screenshot...")
    # For offscreen, grab() might work on the window
    pixmap = window.grab()
    pixmap.save("gui_verification.png")
    print("Screenshot saved to gui_verification.png")

if __name__ == "__main__":
    main()
