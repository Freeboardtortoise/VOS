//structs and starting functions

typedef struct Node {
	uint64_t id;           // unique node ID uint32_t type;         // file, directory, etc.
	size_t size;           // payload size
	time_t created;        // timestamps
	time_t modified;
	uint64_t* edges;       // dynamic array of connected node IDs
	size_t edge_count;
	char* payload;         // file data (optional, for in-memory)
} Node;


typedef struct GraphFS {
	Node* nodes;          // dynamic array of nodes
	uint64_t node_count;
	size_t node_capacity;
} GraphFS;

Node make_node(uint64_t id, uint32_t type, size_t size);
