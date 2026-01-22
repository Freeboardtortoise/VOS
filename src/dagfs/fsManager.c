#include <linux/fs.h>
#include <linux/buffer_head.h>
#include <linux/slab.h>
#include <linux/iversion.h>
#include <linux/unicode.h>
#include <time.h>
#include "structs.h"

GraphFS make_graphfs(size_t size) {
	GraphFS graphfs;
	graphfs.nodes = NULL;
	graphfs.node_capacity = size;
	return graphfs;
}

void free_graphfs(GraphFS graphfs) {
	kvfree(graphfs.nodes);
}

Node get_node_id(GraphFS graphfs, uint64_t id) {
	return graphfs.nodes[id];
}
