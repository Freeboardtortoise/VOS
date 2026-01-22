#include <linux/fs.h>
#include <linux/buffer_head.h>
#include <linux/slab.h>
#include <linux/iversion.h>
#include <linux/unicode.h>
#include <time.h>

#include "structs.h"
#include "nodeManager.h"
#include "fsManager.h"

uint64_t create_node(GraphFS* fs, uint64_t type) {
  Node currentNode = make_node(fs->node_count, type, 0);
  fs->node_count++;
  fs->nodes = krealloc(fs->nodes, fs->node_count * sizeof(Node), GFP_KERNEL);
  fs->nodes[fs->node_count - 1] = currentNode;
  return &fs->nodes[fs->node_count - 1];
  return currentNode->id;
}
void delete_node(GraphFS fs, uint64_t id) {
  fs.nodes[id].id = 0;
  fs.nodes[id].type = 0;
  fs.nodes[id].size = 0;
  fs.nodes[id].created = 0;
  fs.nodes[id].modified = 0;
  fs.nodes[id].edges = NULL;
  fs.nodes[id].edge_count = 0;
  fs.nodes[id].payload = NULL;
  free(fs.nodes[id]);
}
void update_node_payload(GraphFS fs, uint64_t id, char* payload) {
  fs.nodes[id].payload = payload;
}
void update_timestamp(GraphFS, uint64_t id) {
  fs.nodes[id].modified = time();
}
void link_node(GraphFS fs, uint64_t node1, uint64_t node2) {
  node1->edges = krealloc(node1->edges, (node1->edge_count + 1) * sizeof(uint64_t), GFP_KERNEL);
  node1->edges[node1->edge_count] = node2;
  node1->edge_count++;

  node2->edges = krealloc(node2->edges, (node2->edge_count + 1) * sizeof(uint64_t), GFP_KERNEL);
  node2->edges[node2->edge_count] = node1;
  node2->edge_count++;
}
void unlink_nodes(GraphFS fs, uint64_t node1, uint64_t node2) {
  for (int i = 0; i < node1->edge_count; i++) {
    if (node1->edges[i] == node2) {
      node1->edges[i] = node1->edges[node1->edge_count - 1];
      node1->edge_count--;
    }
  }
  for (int i = 0; i < node2->edge_count; i++) {
    if (node2->edges[i] == node1) {
      node2->edges[i] = node2->edges[node2->edge_count - 1];
      node2->edge_count--;
    }
  }
}
bool is_linked(GraphFS fs, uint64_t node1, uint64_t node2) {
  for (int i = 0; i < node1->edge_count; i++) {
    if (node1->edges[i] == node2) {
      return true;
    }
  }
  return false;
}

