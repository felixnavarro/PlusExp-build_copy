IF(OvrvisionPro_DIR)
  FIND_PACKAGE(OvrvisionPro REQUIRED NO_MODULE)

  MESSAGE(STATUS "Using OvrvisionPro available at: ${OvrvisionPro_DIR}")
  
  # Copy libraries to CMAKE_RUNTIME_OUTPUT_DIRECTORY
  PlusCopyLibrariesToDirectory(${CMAKE_RUNTIME_OUTPUT_DIRECTORY} OvrvisionPro)

  SET(PLUS_OvrvisionPro_DIR ${OvrvisionPro_DIR} CACHE INTERNAL "Path to store OvrvisionPro binaries")
ELSE()
  IF(NOT OpenCV_FOUND)
    # We are building our own OpenCV, make sure the dependency order is set
    SET(OvrvisionPro_DEPENDENCIES OpenCV)
  ELSE()
    SET(OvrvisionPro_DEPENDENCIES)
  ENDIF()

  # --------------------------------------------------------------------------
  # OvrvisionPro SDK
  SET (PLUS_OvrvisionPro_src_DIR ${CMAKE_BINARY_DIR}/Deps/OvrvisionPro CACHE INTERNAL "Path to store OvrvisionPro contents.")
  SET (PLUS_OvrvisionPro_prefix_DIR ${CMAKE_BINARY_DIR}/Deps/OvrvisionPro-prefix CACHE INTERNAL "Path to store OvrvisionPro prefix data.")
  SET (PLUS_OvrvisionPro_DIR ${CMAKE_BINARY_DIR}/Deps/OvrvisionPro-bin CACHE INTERNAL "Path to store OvrvisionPro binaries")
  
  # Since OvrvisionPro SDK uses #pragma comment(lib...) commands, we need to pass in the directories containing the requested libraries directly...
  #   ippicvmt.lib
  IF( MSVC AND ${BUILD_ARCHITECTURE} MATCHES "x64" )
    SET(OvrvisionPro_PRAGMA_HACK -DPragmaHack_DIR:PATH=${PLUS_OpenCV_src_DIR}/3rdparty/ippicv/unpack/ippicv_win/lib/intel64)
  ELSEIF(MSVC)
    SET(OvrvisionPro_PRAGMA_HACK -DPragmaHack_DIR:PATH=${PLUS_OpenCV_src_DIR}/3rdparty/ippicv/unpack/ippicv_win/lib/ia32)
  ELSEIF(APPLE)
    # Mac?
  ELSE()
    # Linux?
  ENDIF()

  SetGitRepositoryTag(
    OvrvisionPro
    "${GIT_PROTOCOL}://github.com/PLUSToolkit/OvrvisionProCMake.git"
    "master"
    )

  ExternalProject_Add( OvrvisionPro
    PREFIX ${PLUS_OvrvisionPro_prefix_DIR}
    "${PLUSBUILD_EXTERNAL_PROJECT_CUSTOM_COMMANDS}"
    SOURCE_DIR "${PLUS_OvrvisionPro_src_DIR}"
    BINARY_DIR "${PLUS_OvrvisionPro_DIR}"
    #--Download step--------------
    GIT_REPOSITORY ${OvrvisionPro_GIT_REPOSITORY}
    GIT_TAG ${OvrvisionPro_GIT_TAG}
    #--Configure step-------------
    CMAKE_ARGS
      ${ep_common_args}
      ${OvrvisionPro_PRAGMA_HACK}
      -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      -DCMAKE_LIBRARY_OUTPUT_DIRECTORY:PATH=${CMAKE_LIBRARY_OUTPUT_DIRECTORY}
      -DCMAKE_RUNTIME_OUTPUT_DIRECTORY:PATH=${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
      -DCMAKE_ARCHIVE_OUTPUT_DIRECTORY:PATH=${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}
      -DOpenCV_DIR:PATH=${PLUS_OpenCV_DIR}
    #--Override install step-----------------
    INSTALL_COMMAND "" # Do not install
    #--Dependencies-----------------
    DEPENDS ${OvrvisionPro_DEPENDENCIES}
    )
ENDIF()