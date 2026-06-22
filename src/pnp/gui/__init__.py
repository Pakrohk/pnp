import sys
import os
import re
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtWidgets import QApplication
from loguru import logger
from pnp.gui.backend import Backend
from pnp.gui.tray import TrayManager


class LogSink:
    def __init__(self, backend):
        self.backend = backend

    def write(self, message):
        # Remove ANSI color codes if any
        ansi_escape = re.compile(r'\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
        clean_msg = ansi_escape.sub('', message)
        self.backend.appendLog(clean_msg)


def setup_kde_integration(app, engine):
    """Configure Kirigami and Kvantum for KDE Plasma integration"""

    # 1. Configure QML import paths for Kirigami
    kirigami_paths = [
        "/usr/lib/qt6/qml/",
        "/usr/lib64/qt6/qml/",
        "/usr/lib/x86_64-linux-gnu/qt6/qml/",
        "/usr/lib/aarch64-linux-gnu/qt6/qml/"
    ]

    has_kirigami = False
    for path in kirigami_paths:
        if os.path.exists(os.path.join(path, "org/kde/kirigami")):
            engine.addImportPath(path)
            logger.debug(f"Added Kirigami import path: {path}")
            has_kirigami = True

    # 2. Apply Kvantum theme with fallback
    if has_kirigami:
        try:
            app.setStyle("kvantum")
            logger.info("Kvantum theme applied")
        except Exception:
            try:
                app.setStyle("breeze")
                logger.info("Breeze theme applied as fallback")
            except Exception:
                app.setStyle("fusion")
                logger.info("Fusion theme applied as fallback")
    else:
        app.setStyle("fusion")
        logger.warning("Kirigami not found, falling back to Fusion style")

    return has_kirigami


def main():
    # Ensure src directory is in sys.path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(os.path.dirname(script_dir))
    if project_root not in sys.path:
        sys.path.insert(0, project_root)

    # 1. Set Qt plugin path (includes PySide6 plugins)
    try:
        import PySide6
        pyside6_dir = os.path.dirname(os.path.abspath(PySide6.__file__))
        pyside6_plugins = os.path.join(pyside6_dir, 'Qt6', 'plugins')
        if os.path.exists(pyside6_plugins):
            plugins_path = os.environ.get('QT_PLUGIN_PATH', '')
            if pyside6_plugins not in plugins_path:
                os.environ['QT_PLUGIN_PATH'] = f"{pyside6_plugins}{os.pathsep}{plugins_path}" if plugins_path else pyside6_plugins
    except ImportError:
        pass

    # 2. Detect Kirigami for style selection
    kirigami_paths = [
        "/usr/lib/qt6/qml/",
        "/usr/lib64/qt6/qml/",
        "/usr/lib/x86_64-linux-gnu/qt6/qml/",
        "/usr/lib/aarch64-linux-gnu/qt6/qml/"
    ]
    has_kirigami_sys = any(os.path.exists(os.path.join(p, "org/kde/kirigami")) for p in kirigami_paths)
    if has_kirigami_sys:
        os.environ["QT_QUICK_CONTROLS_STYLE"] = "org.kde.desktop"

    # Use QApplication instead of QGuiApplication for QSystemTrayIcon support
    app = QApplication(sys.argv)
    app.setQuitOnLastWindowClosed(False)
    app.setApplicationName("PNP")
    app.setOrganizationName("pakrohk")
    app.setApplicationVersion("5.2.0")

    engine = QQmlApplicationEngine()

    # KDE Integration (Kirigami & Kvantum)
    has_kirigami = setup_kde_integration(app, engine)

    backend = Backend()
    engine.rootContext().setContextProperty("backend", backend)

    # Tray Management
    tray = TrayManager(app)
    tray.show_window_requested.connect(
        lambda: engine.rootObjects()[0].show() if engine.rootObjects() else None
    )
    tray.quit_requested.connect(app.quit)
    tray.start()

    # Configure Loguru
    logger.remove()  # Remove default handler
    logger.add(
        sys.stderr,
        colorize=True,
        format="<green>{time:HH:mm:ss}</green> | <level>{level: <8}</level> | "
               "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> "
               "- <level>{message}</level>"
    )

    log_sink = LogSink(backend)
    logger.add(
        log_sink.write,
        format="{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {message}\n"
    )

    if has_kirigami:
        qml_file = os.path.join(os.path.dirname(__file__), "qml", "main.qml")
    else:
        qml_file = os.path.join(os.path.dirname(__file__), "qml", "StandardMain.qml")

    engine.load(qml_file)

    if not engine.rootObjects():
        logger.error("Failed to load QML. Check Kirigami installation.")
        sys.exit(-1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
