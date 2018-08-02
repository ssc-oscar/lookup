#include <boost/config.hpp>
#include <ctime>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <boost/graph/use_mpi.hpp>
#include <boost/graph/distributed/mpi_process_group.hpp>
#include <boost/graph/distributed/adjacency_list.hpp>
#include <boost/graph/distributed/connected_components_parallel_search.hpp>
#include <boost/graph/distributed/connected_components.hpp>
#include <boost/iostreams/filtering_stream.hpp>
#include <boost/iostreams/filtering_streambuf.hpp>
#include <boost/iostreams/filter/gzip.hpp>
#include <algorithm>
#include <vector>
#include <queue>
#include <limits>
#include <map>
int main (int argc, char ** argv){
	int gsiz = atoi(argv[1]);
	using namespace boost;
	using boost::graph::distributed::mpi_process_group;
	{
		mpi::environment env(argc, argv);
		mpi::communicator world;


		mpi_process_group pg;

	        int nproc = world.size();

		parallel::variant_distribution<mpi_process_group> distrib 
			      = parallel::block(pg, gsiz);

		typedef adjacency_list < vecS, 
				boost::distributedS<boost::graph::distributed::mpi_process_group, boost::vecS>, 
				undirectedS > Graph;
		
		Graph G (gsiz);
		
                int pid = process_id (G .process_group());
                if (pid == 0) std::cerr << "start;" << time(0) << std::endl;
		if (1) {
			unsigned int a, b;
                        std::stringstream fnames;
                        fnames << argv[2] << "." << std::setw(5) << std::setfill('0') << pid << ".gz";
                        std::string fname = fnames.str ();  
                        std::ifstream file(fname.data(), std::ios_base::in | std::ios_base::binary);
                        boost::iostreams::filtering_istream in;
                        in.push(boost::iostreams::gzip_decompressor());
                        in.push(file);
			in>>a; in>>b;
			//std::cout<<a<<b;
			while (!in.eof()){
				add_edge (vertex(a, G), vertex(b, G), G);
				in>>a;in>>b;
				//if (! ((j++)%1000000000)) std::cerr << j << std::endl;
			}	
			std::cerr << "read;" << pid << ';' << time(0) << std::endl;
		}

		synchronize(G);
                if (pid == 0) std::cerr << "read;" << time(0) << std::endl;
               

		int nv = num_vertices(G);
		//std::cerr << "Created local graph " << process_id (G .process_group()) << 
		//	" with " << nv << " vertices" << std::endl;
		
		std::vector<long int> lcomponent (num_vertices(G));
		typedef iterator_property_map<std::vector<long int>::iterator, 
				property_map<Graph, vertex_index_t>::type> ComponentMap;
		ComponentMap component (lcomponent.begin(), get (vertex_index, G));
                
                std::stringstream fnames;
                fnames << argv[3] << "." << std::setw(5) << std::setfill('0') << pid << ".gz";
                std::ofstream file(fnames.str().data(), std::ios_base::out | std::ios_base::binary);
                boost::iostreams::filtering_ostream out;
                out .push(boost::iostreams::gzip_compressor());
                out .push(file);

		//out << "Created components for local graph " << pid <<
		//	" with " << nv << " vertices" << std::endl;
		int num = connected_components_ps (G, component);
	        //synchronize(component);
                //out << "computed;" << pid << ';' << time(0) << std::endl;
		if (pid == 0){ 
                   component.set_max_ghost_cells(0);
                   synchronize(component);
                }else{
                   synchronize(component);
                }
		if (pid == 0) std::cerr << "connected;" << time(0) << ";components" << std::endl;
                //for (int i = 0; i < nv; i++){
                //for (int i = from; i < nv; i++){
			
                synchronize(G .process_group());   
                synchronize(component);
                typedef graph_traits<Graph>::vertex_iterator vertex_iter;
                std::pair<vertex_iter, vertex_iter> lG;
                typedef property_map<Graph, vertex_index_t>::type IndexMap;
                IndexMap index = get(vertex_index, G);
                for (lG = vertices(G); lG.first != lG.second; ++lG.first){
                   out << index [*lG.first] << ';' << get (component, *lG.first) << std::endl;
                }         
		//if (0){
                //int from = gsiz*pid/nproc;
                //int to = gsiz*(pid+1)/nproc;
                //if (pid == nproc-1) to = gsiz;
		//for (int i = from; i < to; i++){
		//	int c = get (component, vertex(i, G));
		//	out << i << ";" << c << std::endl;
		//}//}
                synchronize(G .process_group());
                if (pid == 0) std::cerr << "done;" << time(0)  << std::endl;
		//	synchronize(component);
		//}else{
		//	synchronize(component);
		//}
		//write_graphviz("cc.dot", G, paint_by_number(component));
	}
	return 0;
}
