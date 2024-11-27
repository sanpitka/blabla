cmake_minimum_required(VERSION 3.16)

project(Blabla VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Core Quick Network)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appBlabla
    main.cpp
)

qt_add_qml_module(appBlabla
    URI Blabla
    VERSION 1.0
    QML_FILES
        Main.qml
        SOURCES server.h
        SOURCES server.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appBlabla PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appBlabla
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appBlabla
    PRIVATE Qt6::Core Qt6::Quick Qt6::Network
)

include(GNUInstallDirs)
install(TARGETS appBlabla
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
