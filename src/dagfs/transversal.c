#include <linux/fs.h>
#include <linux/buffer_head.h>
#include <linux/slab.h>
#include <linux/iversion.h>
#include <linux/unicode.h>
#include <time.h>

#include "structs.h"
#include "nodeManager.h"
#include "fsManager.h"

uint64_t[] get_children(GraphFS fs, uint64_t id) {
  return fs.nodes[id].edges;
}
