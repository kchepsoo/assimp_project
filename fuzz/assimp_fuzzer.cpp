#include <cstddef>
#include <cstdint>
#include <string>

#include <assimp/Importer.hpp>
#include <assimp/postprocess.h>
#include <assimp/scene.h>

extern "C" int LLVMFuzzerTestOneInput(const uint8_t* data, size_t size) {
  if (data == nullptr || size < 2) {
    return 0;
  }

  if (size > 1024 * 1024) {
    return 0;
  }

  static const char* const hints[] = {
      "obj", "fbx", "dae", "stl", "ply", "gltf", "glb",
      "3ds", "x", "md5mesh", "lwo", "ase", "bvh", "off"
  };

  const char* hint = hints[data[0] % (sizeof(hints) / sizeof(hints[0]))];

  Assimp::Importer importer;
  importer.SetPropertyInteger("AI_CONFIG_IMPORT_TER_MAKE_UVS", 1);

  const unsigned int flags =
      aiProcess_Triangulate |
      aiProcess_JoinIdenticalVertices |
      aiProcess_ValidateDataStructure |
      aiProcess_FindInvalidData |
      aiProcess_GenNormals;

  const aiScene* scene =
      importer.ReadFileFromMemory(data + 1, size - 1, flags, hint);

  if (scene != nullptr) {
    volatile unsigned int mesh_count = scene->mNumMeshes;
    (void)mesh_count;
  }

  return 0;
}
