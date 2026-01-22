uint64_t create_node(GraphFS fs, uint64_t type); //return id
void delete_node(GraphFS fs, uint64_t id);
void update_node_payload(GraphFS fs, uint64_t id, char* payload);
void update_timestamp(GraphFS fs, uint64_t id);
void link_node(GraphFS fs, uint64_t node1, uint64_t node2);
void unlink_nodes(GraphFS fs, uint64_t node1, uint64_t node2);
bool is_linked(GraphFS fs, uint64_t node1, uint64_t node2);
