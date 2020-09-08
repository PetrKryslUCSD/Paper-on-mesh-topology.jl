# petsc-3.13.5/src/dm/impls/plex/tutorials/ex1.c

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

C_code_w_mem_est = """
static char help[] = "Exhaustive memory tracking for DMPlex.\n\n\n";

#include <petscdmplex.h>

static PetscErrorCode EstimateMemory(DM dm, PetscLogDouble *est)
{
  DMLabel        marker;
  PetscInt       cdim, depth, d, pStart, pEnd, p, Nd[4] = {0, 0, 0, 0}, lsize = 0, rmem = 0, imem = 0;
  PetscInt       coneSecMem = 0, coneMem = 0, supportSecMem = 0, supportMem = 0, labelMem = 0;
  PetscErrorCode ierr;

  PetscFunctionBeginUser;
  PetscPrintf(PETSC_COMM_SELF, "Memory Estimates\n");
  ierr = DMGetCoordinateDim(dm, &cdim);CHKERRQ(ierr);
  ierr = DMPlexGetDepth(dm, &depth);CHKERRQ(ierr);
  ierr = DMPlexGetChart(dm, &pStart, &pEnd);CHKERRQ(ierr);
  for (d = 0; d <= depth; ++d) {
    PetscInt start, end;

    ierr = DMPlexGetDepthStratum(dm, d, &start, &end);CHKERRQ(ierr);
    Nd[d] = end - start;
  }
  /* Coordinates: 3 Nv reals + 2*Nv + 2*Nv ints */
  rmem += cdim*Nd[0];
  imem += 2*Nd[0] + 2*Nd[0];
  PetscPrintf(PETSC_COMM_SELF, "  Coordinate mem: %D %D\n", cdim*Nd[0]*sizeof(PetscReal), 4*Nd[0]*sizeof(PetscInt));
  /* Depth:       Nc+Nf+Ne+Nv ints */
  for (d = 0; d <= depth; ++d) labelMem += Nd[d];
  /* Cell Type:   Nc+Nf+Ne+Nv ints */
  for (d = 0; d <= depth; ++d) labelMem += Nd[d];
  /* Marker */
  ierr = DMGetLabel(dm, "marker", &marker);CHKERRQ(ierr);
  if (marker) {ierr = DMLabelGetStratumSize(marker, 1, &lsize);CHKERRQ(ierr);}
  labelMem += lsize;
  PetscPrintf(PETSC_COMM_SELF, "  Label mem:      %D\n", labelMem*sizeof(PetscInt));
   /* Cones and Orientations:       4 Nc + 3 Nf + 2 Ne ints + (Nc+Nf+Ne) ints no separate orientation section */
  for (d = 0; d <= depth; ++d) coneSecMem += 2*Nd[d];
  for (p = pStart; p < pEnd; ++p) {
    PetscInt csize;

    ierr = DMPlexGetConeSize(dm, p, &csize);CHKERRQ(ierr);
    coneMem += csize;
  }
  PetscPrintf(PETSC_COMM_SELF, "  Cone mem:       %D %D\n", coneMem*sizeof(PetscInt), coneSecMem*sizeof(PetscInt));
  imem += 2*coneMem + coneSecMem;
  /* Supports:       4 Nc + 3 Nf + 2 Ne ints + Nc+Nf+Ne ints */
  for (d = 0; d <= depth; ++d) supportSecMem += 2*Nd[d];
  for (p = pStart; p < pEnd; ++p) {
    PetscInt ssize;

    ierr = DMPlexGetSupportSize(dm, p, &ssize);CHKERRQ(ierr);
    supportMem += ssize;
  }
  PetscPrintf(PETSC_COMM_SELF, "  Support mem:    %D %D\n", supportMem*sizeof(PetscInt), supportSecMem*sizeof(PetscInt));
  imem += supportMem + supportSecMem;
  *est = ((PetscLogDouble) imem)*sizeof(PetscInt) + ((PetscLogDouble) rmem)*sizeof(PetscReal);
  PetscFunctionReturn(0);
}
int main(int argc, char **argv)
{
  DM             dm;
  PetscInt       dim = 3;
  const PetscInt faces[] = {21, 27, 30};
  //const PetscInt faces[] = {1, 1, 1};
  PetscBool      interpolate = PETSC_TRUE;
  PetscErrorCode ierr;
  PetscLogDouble before, after, est, clean;

  ierr = PetscInitialize(&argc, &argv, NULL,help);if (ierr) return ierr;
  ierr = PetscOptionsGetInt(NULL,NULL, "-dim", &dim, NULL);CHKERRQ(ierr);
  ierr = PetscMallocGetCurrentUsage(&before);CHKERRQ(ierr);
  /* Create a mesh */
  ierr = DMPlexCreateBoxMesh(PETSC_COMM_WORLD, dim, PETSC_TRUE, faces, NULL, NULL, NULL, interpolate, &dm);CHKERRQ(ierr);
  DMViewFromOptions(dm,NULL,"-dm_view");
  ierr = PetscMallocGetCurrentUsage(&after);CHKERRQ(ierr);
  ierr = EstimateMemory(dm, &est);CHKERRQ(ierr);
  ierr = DMDestroy(&dm);CHKERRQ(ierr);
  ierr = PetscMallocGetCurrentUsage(&clean);CHKERRQ(ierr);
  ierr = PetscPrintf(PETSC_COMM_WORLD, "Measured Memory\n  Initial memory   %D\n  Memory for mesh  %D\n  Estimated memory %D discrepancy %D\n  Extra memory to build mesh %D\n  Memory after destroy %D", (PetscInt) before, (PetscInt) (after-before), (PetscInt) est, (PetscInt) PetscAbsReal(after-before-est), (PetscInt) clean);CHKERRQ(ierr);
  ierr = PetscFinalize();
  return ierr;
}
"""

# Reported by the running program:
# Labels:
#   celltype: 4 strata with value/size (0 (19096), 6 (102060), 3 (208134), 1 (125169))
#   depth: 4 strata with value/size (0 (19096), 1 (125169), 2 (208134), 3 (102060))
#   marker: 1 strata with value/size (1 (12798))
# **************************************************
# Allocated 2.38068e+07 bytes
# **************************************************

# Calculation according to Matt Knepley:
Nv =  19096
Ne = 125169
Nf = 208134
Nc = 102060
total = 3*Nv*8 + 
(Nc+Nf+Ne+Nv)*4 + 
(Nc+Nf+Ne+Nv)*4 + 
2* (4*Nc + 3*Nf + 2*Ne)*4 +
(Nc+Nf+Ne)*4 + 
(Nf+Ne+Nv)*4 + Nv*4
@show total/2^20
# 16.7 MB for 64-bit integers vs. 6.7 MB for 32-bit integers