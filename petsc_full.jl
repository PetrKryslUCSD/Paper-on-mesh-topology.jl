C_code ="""
#include <petscdmplex.h>

int main(int argc, char **argv)
{
  DM             dm;
  PetscInt       dim = 3;
  const PetscInt faces[] = {21, 27, 30};
  //const PetscInt faces[] = {1, 1, 1};
  PetscBool      interpolate = PETSC_TRUE;
  PetscErrorCode ierr;
  PetscLogDouble spac;

  ierr = PetscInitialize(&argc, &argv, NULL,help);if (ierr) return ierr;
  ierr = PetscOptionsGetInt(NULL,NULL, "-dim", &dim, NULL);CHKERRQ(ierr);
  /* Create a mesh */
  ierr = DMPlexCreateBoxMesh(PETSC_COMM_WORLD, dim, PETSC_TRUE, faces, NULL, NULL, NULL, interpolate, &dm);CHKERRQ(ierr);
  DMViewFromOptions(dm,NULL,"-dm_view");
  ierr = PetscMallocGetCurrentUsage(&spac);
  printf("**************************************************\n");
  printf("Allocated %g bytes\n", spac);
  printf("**************************************************\n");
  ierr = DMDestroy(&dm);CHKERRQ(ierr);
  ierr = PetscFinalize();
  return ierr;
}
"""

C_code_ud = """
#include <petscdmplex.h>

int main(int argc, char **argv)
{
  DM             dm;
  DM             dmUnint;
  PetscInt       dim = 3;
  const PetscInt faces[] = {21, 27, 30};
  //const PetscInt faces[] = {1, 1, 1};
  PetscBool      interpolate = PETSC_TRUE;
  PetscErrorCode ierr;
  PetscLogDouble spac;

  ierr = PetscInitialize(&argc, &argv, NULL,help);if (ierr) return ierr;
  ierr = PetscOptionsGetInt(NULL,NULL, "-dim", &dim, NULL);CHKERRQ(ierr);
  /* Create a mesh */
  ierr = DMPlexCreateBoxMesh(PETSC_COMM_WORLD, dim, PETSC_TRUE, faces, NULL, NULL, NULL, interpolate, &dm);CHKERRQ(ierr);
  ierr = DMPlexUninterpolate(dm, &dmUnint);CHKERRQ(ierr);
  ierr = DMDestroy(&dm);CHKERRQ(ierr);
  dm = dmUnint;
  DMViewFromOptions(dm,NULL,"-dm_view");
  ierr = PetscMallocGetCurrentUsage(&spac);
  printf("**************************************************\n");
  printf("Allocated %g bytes\n", spac);
  printf("**************************************************\n");
  ierr = DMDestroy(&dm);CHKERRQ(ierr);
  ierr = PetscFinalize();
  return ierr;
}
"""

# Calculation according to Matt Knepley:
Nv =  19096
Ne = 125169
Nf = 208134
Nc = 102060
# Labels:
#   celltype: 4 strata with value/size (0 (19096), 6 (102060), 3 (208134), 1 (125169))
#   depth: 4 strata with value/size (0 (19096), 1 (125169), 2 (208134), 3 (102060))
#   marker: 1 strata with value/size (1 (12798))
# **************************************************
# Allocated 2.38068e+07 bytes
# **************************************************
total = 3*Nv*8 + 
(Nc+Nf+Ne+Nv)*4 + 
(Nc+Nf+Ne+Nv)*4 + 
2* (4*Nc + 3*Nf + 2*Ne)*4 +
(Nc+Nf+Ne)*4 + 
(Nf+Ne+Nv)*4
@show total/2^20
# 16.7 MB for 64-bit integers vs. 6.7 MB for 32-bit integers