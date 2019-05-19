#include <igraph.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

void print_vector(igraph_vector_t *v) {
  long int i, l = igraph_vector_size(v);
  if (l > 0) printf ("%li", (long int) VECTOR(*v)[0]);
  for (i=1; i<l; i++) {
    printf (";%li", (long int) VECTOR(*v)[i]);
  }
  if (l > 0) printf("\n");
}

char * frS = "a2pFullO.torvalds";

int main(int argc, char ** argv)
{
  if (argc > 2) frS = argv[2];
  FILE *f = fopen (frS, "r");
  int nal = 0;
  int vals [1000];
  int i;
  size_t len = 0;
  char * line = NULL; 
  ssize_t read;
  while ((read = getline(&line, &len, f)) != -1) {
    sscanf (line, "%d", vals + nal++);
  }
  fprintf (stderr, "read %d aliases\n", nal);
  igraph_vector_t frV;
  igraph_vector_init(&frV, nal);
  for (i = 0; i < nal; i++) VECTOR(frV)[i]=vals[i]-1;
  
  //int * as = (int*) malloc (40000000*sizeof(int));
  //int nas = 0;
  //f = fopen ("a2pFullO.as", "r");  
  //while ((read = getline(&line, &len, f)) != -1) {
  //  sscanf (line, "%d", as+(nas++));
  //}
  //igraph_vector_t toV;
  //igraph_vector_init(&toV, nas);
  //for (i = 0; i < nas; i++) VECTOR(toV)[i]=as[i];
  //fprintf (stderr, "read %d authors\n", nas);

  int n = atoi (argv[1]);
  igraph_integer_t d;
  igraph_t g;
  int res = igraph_read_graph_edgelist(&g, stdin, n, 0);
  fprintf (stderr, "read adjacencies\n");
 
  igraph_vs_t fr;
  igraph_vs_vector (&fr, &frV);
  //igraph_vs_t to;
  //igraph_vs_all (&to);
  //igraph_vs_1 (&fr, 0);
  //igraph_vs_1 (&to, 1000);
  if (1){
    igraph_matrix_t dist;
    igraph_matrix_init(&dist, nal, n);
    res = igraph_shortest_paths (&g, &dist, fr, igraph_vss_all(), IGRAPH_ALL);
    fprintf (stderr, "calculated distances\n");
  
    igraph_vector_t row;
    igraph_vector_init(&row, nal);
    for (i = 0; i < n; i++){
      igraph_matrix_get_col (&dist, &row, i);
      igraph_real_t mv = igraph_vector_min (&row);
      //printf ("%d;%d;%f\n", i, as[i], mv);
      //int ll = igraph_vector_size(&row);
      printf ("%d;%f\n", i, mv);
    }
    igraph_matrix_destroy(&dist);
  }
  if (0){
    igraph_vector_ptr_t vr;
    igraph_vector_ptr_init (&vr, n);
    for (i=0; i<igraph_vector_ptr_size(&vr); i++) {
      VECTOR(vr)[i] = calloc(1, sizeof(igraph_vector_t));
      igraph_vector_init(VECTOR(vr)[i], 0);
    }
    for (int j = 0; j < nal; j++){
      igraph_get_shortest_paths(&g, &vr, NULL, VECTOR(frV)[j], igraph_vss_all(), IGRAPH_ALL, NULL, NULL);
      fprintf (stderr, "calculated paths for %d\n", j);
      for (i=0; i<igraph_vector_ptr_size(&vr); i++) {
        print_vector (VECTOR(vr)[i]);
      }
    }
    for (i=0; i<igraph_vector_ptr_size(&vr); i++) {
      igraph_vector_destroy (VECTOR(vr)[i]);
      free (VECTOR(vr)[i]);
    }
    igraph_vector_ptr_destroy(&vr);
  }
  if (0){
    igraph_diameter(&g, &d, 0, 0, 0, IGRAPH_UNDIRECTED, 1);
    printf("Diameter of a random graph with average degree 5: %d\n", (int) d);
  }
  igraph_destroy(&g);
  return 0;
}
