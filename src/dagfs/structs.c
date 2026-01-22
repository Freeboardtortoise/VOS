#include <linux/fs.h>
#include <linux/buffer_head.h>
#include <linux/slab.h>
#include <linux/iversion.h>
#include <linux/unicode.h>
#include <time.h>
#include "structs.h"


// starting functions

Node make_node(uint64_t id, uint32_t type, size_t size) {
    Node node;
    node.id = id;
    node.type = type;
    node.size = size;
    node.created = time();
    node.modified = time();
    node.edges = NULL;
    node.edge_count = 0;
    node.payload = NULL;
    return node;
}
