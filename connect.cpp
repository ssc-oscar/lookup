#include <boost/config.hpp>
#include <iostream>
#include <vector>
#include <boost/graph/connected_components.hpp>
#include <boost/graph/adjacency_list.hpp>
//using namespace std;
//extern std::istream cin;
//extern std::ostream cout;
int main (){
	using namespace boost;
	{
		typedef adjacency_list < vecS, vecS, undirectedS > Graph;
		Graph G;
		long int a, b, j = 0;
		std::cin>>a;std::cin>>b;
		while (!std::cin.eof()){
			add_edge (a, b, G);
			std::cin>>a;std::cin>>b;
			if (! ((j++)%100000000)) std::cerr << j << std::endl;
		}
		std::cerr << "done reading:" << j << std::endl;

		std::vector <long int> component (num_vertices(G));
		std::cerr << "Created graph" << std::endl;

		int num = connected_components (G, &component[0]);
		std::cerr << "Connected graph" << std::endl;

		std::vector <long int>::size_type i;
		for (i = 0; i != component.size(); ++i){
			std::cout << i << ";" << component[i] << std::endl;
		}
	}
	return 0;
}
