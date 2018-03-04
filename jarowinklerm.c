#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <stdio.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#define handle_error(msg) \
           do { perror(msg); exit(EXIT_FAILURE); } while (0)
/*
 * Implementierung der Jaro-Metrik
 * 
 * Eingabe:
 *  str_1, str_2    : die zu vergleichenden Zeichenketten
 *  W_1, W_2, W_t   : Gewichte für Berechnung der Ähnlichkeit
 *  r               : Radiuskoeffizient. Es werden gemeinsame Zeichen im
 *                    Radius r * max(length(str_1),length(str_2) betrachtet
 *  transpos_radius : gibt an, wie weit ein gemeinsame Zeichen voneinander
 *                    entfernt sein dürfen, ohne als Transposition zu zählen                
 * Ausgabe:         Ähnlichkeitsmaß im Intervall [0, W_1 + W_2 + W_3]
 */

int getCommonCharacters(char * common, const char * str_1, 
                          const char * str_2, int radius);             
  
int getTranspositions(char * common_1, char * common_2, int radius);

double jaro(const char * str_1, const char * str_2, 
             double W_1, double W_2, double W_t,
             double r, int use_transpos_radius);

void jarowinkler(const char ** strvec_1, const char ** strvec_2,
             int * length_1, int * length_2,
             double * W_1, double * W_2, double * W_t,
             double * r, double * ans);

double jarowinkler_core(const char * str_1, const char * str_2,
             double W_1, double W_2, double W_t,
             double r);
						  

// version for .C call, slow because arguments are duplicated
void jarowinkler(const char ** strvec_1, const char ** strvec_2,
             int * length_1, int * length_2,
             double * W_1, double * W_2, double * W_t,
             double * r, double * ans)
{
  //Rprintf("Einstieg in Funktion\n"); // Debug-Ausgabe
  int * use_transpos_radius=(int *) calloc(1,sizeof(int));
  *use_transpos_radius=0;
  int max_length= *length_1 > *length_2 ? *length_1 : *length_2;  
  for (int str_ind=0; str_ind < max_length; str_ind++)
  {
    const char * str_1=strvec_1[str_ind % *length_1];
    const char * str_2=strvec_2[str_ind % *length_2];
    ans[str_ind]=jarowinkler_core(str_1, str_2, *W_1, *W_2, *W_t, *r);
//     int str_len_1=strlen(str_1);
//     int str_len_2=strlen(str_2);
//   
//     /* Standard-Jaro-Score berechnen */
//     // Rprintf("Berechne Standard-Jaro-Gewicht\n"); // Debug-Ausgabe
//     double jaro_score=jaro(str_1, str_2, *W_1, *W_2, *W_t, *r, *use_transpos_radius);
//   
//     // Rprintf("Berechne daraus Jaro-Winkler\n"); // Debug-Ausgabe
//     /* wenn jaro() 1 oder 0 zurückgibt, ist das der endgültige Wert */
//     if (jaro_score==1.0 || jaro_score==0.0)
//       ans[str_ind]=jaro_score;
//       
//     /* else */
//     // Rprintf("Ermittle Anzahl der Zeichen, für die die Stringanfänge übereinstimmen\n"); // Debug-Ausgabe
//     /* Ermittle Anzahl der Zeichen, für die die Stringanfänge übereinstimmen */
//     int min_str_len=str_len_1<str_len_2 ? str_len_1 : str_len_2;
//     int max_i=0;  
//     while (str_1[max_i]==str_2[max_i] && max_i<4 && max_i<min_str_len)
//     {
//       max_i++;
//     }
//     ans[str_ind]=jaro_score + max_i * 0.1 * (1-jaro_score);
  }
} 


double jarowinkler1 (const char * str_1, const char * str_2){
  int str_len_1=strlen(str_1);
  int str_len_2=strlen(str_2);
  double jaro_score=jaro(str_1, str_2, .333, .333, .333, 0.5, 0);
  if (jaro_score==1.0 || jaro_score==0.0) return(jaro_score);
  int min_str_len=str_len_1<str_len_2 ? str_len_1 : str_len_2;
  int max_i=0;
  while (str_1[max_i]==str_2[max_i] && max_i<4 && max_i<min_str_len){
    max_i++;
  }
  return(jaro_score + max_i * 0.1 * (1-jaro_score));
}

double jarowinkler_core(const char * str_1, const char * str_2,
             double W_1, double W_2, double W_t,
             double r)
{
  int str_len_1=strlen(str_1);
  int str_len_2=strlen(str_2);

  /* Standard-Jaro-Score berechnen */
  // Rprintf("Berechne Standard-Jaro-Gewicht\n"); // Debug-Ausgabe
  double jaro_score=jaro(str_1, str_2, W_1, W_2, W_t, r, 0);

  // Rprintf("Berechne daraus Jaro-Winkler\n"); // Debug-Ausgabe
  /* wenn jaro() 1 oder 0 zurückgibt, ist das der endgültige Wert */
  if (jaro_score==1.0 || jaro_score==0.0)
    return(jaro_score);
    
  /* else */
  // Rprintf("Ermittle Anzahl der Zeichen, für die die Stringanfänge übereinstimmen\n"); // Debug-Ausgabe
  /* Ermittle Anzahl der Zeichen, für die die Stringanfänge übereinstimmen */
  int min_str_len=str_len_1<str_len_2 ? str_len_1 : str_len_2;
  int max_i=0;  
  while (str_1[max_i]==str_2[max_i] && max_i<4 && max_i<min_str_len)
  {
    max_i++;
  }
  return(jaro_score + max_i * 0.1 * (1-jaro_score));

}
#define MAXROW 150000
#define TOP 5
#define MAXLINE 2600015
typedef struct {
  char * d;
  int len;
} dat;

dat getVal (const char * k){
  char s [200];
  struct stat sb;
  sprintf(s, "authors.%s", k);
  int fd = open(s, O_RDONLY);
  if (fd == -1) handle_error("open");
  if (fstat(fd, &sb) == -1) handle_error("fstat");
  char *addr;
  addr = mmap(NULL, sb.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
  if (addr == MAP_FAILED) handle_error("mmap");
  dat d;
  d .d = addr;
  d .len = sb.st_size;
  return d;
}


int main (int argc, const char ** argv){
  double W_1 = 1.0/3;
  double W_2 = 1.0/3;
  double W_t = 1.0/3;
  double r = 0.5;
  dat d0 = getVal(argv[1]);
  dat d1 = getVal(argv[2]);
  float * top200 = (float*)calloc(5*TOP,sizeof(float));
  int * top200i = (int*)calloc(5*TOP,sizeof(int));
  if (top200 == 0 || top200i == 0){
    fprintf (stderr, "cant allocate top200\n");
    exit (-1);
  }
  int i = 0;
  char* tok = 0;
  char* ptok = d0 .d;
  char * buff = (char *)  malloc (MAXLINE);
  char * buff1 = (char *) malloc (MAXLINE);
  if (buff == 0) handle_error("buff");
  if (buff1 == 0) handle_error("buff1");
  char * buffA = buff;
  char * buff1A = buff1;

  while ( (tok = index (ptok, '\n')) != 0){
    if (tok-ptok-2 > MAXLINE){
      fprintf (stderr, "too large line i=%d len=%d\n", i, tok-ptok-1);
      i++;
      buff = buffA;
      ptok = tok+1;
      continue;
    }
    //fprintf (stderr, "i=%d %p %p %d\n%.96s\n%.96s\n",i, ptok, tok, tok-ptok, ptok, tok+1);
    strncpy (buff, ptok, tok-ptok);
    buff[tok-ptok]=0;
    //fprintf (stderr, "str=%s\n", buff);
    ptok = tok+1;
    char * fn [6];
    for (int l = 0; l < 5; l++)
      fn [l] = strsep (&buff, ";");
    fn[5] = fn[4]+strlen(fn[4])+1;
    //fprintf (stderr, "fn[5]=|%s|\n", fn[5]);
    int j = 0;
    char * tokj;
    char * ptokj = d1 .d;
    for (int l = 0; l < 5*TOP; l++) top200 [l] = 0;
    while ( (tokj = index (ptokj, '\n')) != 0){
      if (tokj-ptokj-2 > MAXLINE){
        fprintf (stderr, "too large line j=%d i=%d len=%d\n", i, j, tokj-ptokj-1);
        j++;
        ptokj = tokj+1;
        continue;
      }
      //fprintf (stderr, "i=%d j=%d %p %p %d\n%.96s\n%.96s\n",i, j, ptokj, tokj, tokj-ptokj, ptokj, tokj+1);
      if (buff1A != buff1){fprintf (stderr, "bad\n");}
      strncpy (buff1, ptokj, tokj-ptokj);
      buff1[tokj-ptokj]=0;
      ptokj = tokj+1;
      char * fnj [6];
      for (int l = 0; l < 5; l++)
        fnj [l] = strsep (&buff1, ";");
      fnj[5] = fnj[4]+strlen(fnj[4])+1;      
      //fprintf (stderr, "fnj[5]=|%s|\n", fnj[5]);
      for (int l = 0; l < 5; l++){ 
        double ans = jarowinkler1 (fn[l], fnj[l]);
        if (j < TOP){
          top200 [j*5+l] = ans;
          top200i [j*5+l] = j;
        }else{
          for (int k = 0; k < TOP; k++){
            if (ans > top200 [k*5+l]){
              top200 [k*5+l] = ans;
              top200i [k*5+l] = j;
              break;
            }
          }
        }
      }
      buff1 = buff1A; 
      j++;
    }
    for (int l = 0; l < 5; l++){ 
      for (int k = 0; k < TOP; k++){
        if (top200 [k*5+l] > 0){
          printf ("%d;%d;%d;%f\n", l, i, top200i[k*5+l], top200 [k*5+l]);
        }
      }
    }
    //fprintf (stderr,"%s;%d\n", fn[4]+strlen(fn[4])+1, 5);
    buff = buffA;
    i++;
  }
}  

double jaro(const char * str_1, const char * str_2, 
             double W_1, double W_2, double W_t,
             double r, int use_transpos_radius)
{
  int str_len_1=strlen(str_1);
  int str_len_2=strlen(str_2);

  /* wenn eine Zeichenkette leer ist, gib 0 zurück */
  if (str_len_1==0 || str_len_2==0)
    return 0;

  int max_len=str_len_1>str_len_2 ? str_len_1 : str_len_2;

  /* Suchradius. radius==0 bedeutet, dass nur die gleiche Position betrachtet
   * wird, radius==k, dass Poitionen bis einschließlich Entfernung k betrachtet 
   * werden
   */   
  int radius;
  // Wenn beide Zeichenketten Länge 1 haben, setze Radius auf 0 
  if(max_len==1)
    radius=0;
  else

  radius=(int)((r * max_len - 1));
  if (radius<0)
    radius=0;
  
/* Gemeinsame Zeichen suchen */
    
  char * common_1=(char *)calloc(1,str_len_1+1);
  char * common_2=(char *)calloc(1,str_len_2+1);
  int ncommon;
  ncommon=getCommonCharacters(common_1, str_1, str_2, radius);
  /* Falls ncommon==0 ist die Ausgabe 0 */
  if (ncommon==0)
    return 0;
  // Die Anzahl der Zeichen muss nur einmal bestimmt werden
  getCommonCharacters(common_2, str_2, str_1, radius);
  
/* Anzahl der Transpositionen bestimmen */

double retVal;
if (!use_transpos_radius)
{
  int ntranspos;
  ntranspos=getTranspositions(common_1, common_2, 0);
  /*  double ntranspos;
    ntranspos=0.2 * getTranspositions(common_1, common_2, transpos_radius)
                    +0.8 * getTranspositions(common_1, common_2, 0);
   */ 
    /* Ausgabe: gewichtete Summe nach Jaro/Winkler */
    retVal=(double) W_1 * (ncommon/(double)str_len_1) 
                         + W_2 * (ncommon/(double)str_len_2)
                         + W_t * (ncommon-ntranspos)/(double)ncommon;

} else
{

  int ntranspos;
  int ntranspos_with_radius;
  ntranspos=getTranspositions(common_1, common_2, 0);
  ntranspos_with_radius=getTranspositions(common_1, common_2, 1);
  int min_str_len=str_len_1<str_len_2 ? str_len_1 : str_len_2;
  double W_r= ((double) ntranspos - ntranspos_with_radius) / min_str_len;  
  retVal=(double) W_1 * (ncommon/(double)str_len_1) 
                        + W_2 * (ncommon/(double)str_len_2)
                        + W_t * (1-W_r) * (ncommon-ntranspos)/(double)ncommon;
  
  


}
  //free(common_1);
  //free(common_2);
  return retVal;

} 


/*
 * Eingabe:
 *  str_1, str_2  : Zeichenketten
 *  radius        : Radius, bis einschließlich dem gesucht wird
 *    
 * Ausgabe:
 *  common        : gemeinsame Zeichen
 *   
 * Rückgabewert:  : Anzahl der Gemeinsamen Zeichen 
 * 
 * unter common muss Speicher von mindestes length(str_1) Größe zugewiesen sein
 */      
int getCommonCharacters(char * common, const char * str_1, 
                        const char * str_2, int radius)
{
  /* Im zweiten String werden Zeichen als gelöscht markiert,
   * kopiere deshalb um
   */   
  int str_len_1=strlen(str_1);
  int str_len_2=strlen(str_2);
  /* speichert die aktuelle Position in common */
  int common_pos=0;
  char * str_2_temp=(char *)calloc(1,str_len_2+1);
  strcpy(str_2_temp, str_2);
  
  // Zählvariablen
  int cur_pos; /* Zeichenposition in str_1 */
  int search_pos; /* Suchposition in str_1 */


  for (cur_pos=0; cur_pos<str_len_1; cur_pos++)
  {
    // Position, ab der nach gemeinsamem Zeichen gesucht wird
    int search_start_pos=cur_pos-radius>0 ? cur_pos - radius : 0;
    int search_end_pos=cur_pos + radius + 1<str_len_2 ? 
                       cur_pos + radius + 1: str_len_2;
    for (search_pos=search_start_pos; search_pos<search_end_pos; search_pos++)
    {
      if (str_1[cur_pos]==str_2_temp[search_pos])
      {
        common[common_pos]=str_1[cur_pos];
        str_2_temp[search_pos]='\0';
        common_pos++;
        break;
      }
    }
  }
  // String mit gemeinsamen Zeichen terminieren
  common[common_pos]='\0';
  // Zwischenspeicher freigeben
  //free(str_2_temp);
  return (common_pos);
}             


int getTranspositions(char * common_1, char * common_2, int radius)
{
  int cur_pos;
  int search_pos;
  int common_len_1=strlen(common_1);
  int common_len_2=strlen(common_2);
  int ntranspositions=0;

  char * common_2_temp=(char *)calloc(1,common_len_2+1);
  strcpy(common_2_temp, common_2);
  
  //double transpos_distance=0;
  
  for (cur_pos=0; cur_pos<common_len_1; cur_pos++)
  {
    int istransposition=1;
    int search_start_pos=cur_pos - radius>0 ? cur_pos - radius : 0;
    int search_end_pos=cur_pos + radius + 1<common_len_2 ? 
                    cur_pos + radius + 1: common_len_2;
    for (search_pos=search_start_pos; search_pos<search_end_pos; search_pos++)
    {
      if (common_1[cur_pos]==common_2_temp[search_pos])
      {
        common_2_temp[search_pos]='\0';
/*        transpos_distance=abs(cur_pos-search_pos); */
        istransposition=0;
        break;
      }
    }
    if (istransposition)
        ntranspositions++;      
  }
//  free(common_2_temp);
  return ntranspositions/2;
  //ntranspositions/=2;
//  printf("%f\n", transpos_distance);
//  return floor(ntranspositions / 2.0 + transpos_distance);
}  
