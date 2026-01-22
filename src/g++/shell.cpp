//    shell for the bitHavok language and running such programs
//    Copyright (C) 2025  Freeboardtortoise
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.

//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.

//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#include <iostream>
#include <vector>
#include <unordered_map>
#include <functional>
#include <string>
#include <fstream>
#include <sstream>
#include <thread>
#include <chrono>
#include <algorithm>
#include <cctype>

using namespace std;

// -------------------- CONTEXT --------------------
struct Context {
    vector<uint8_t> memory;
    unordered_map<int, uint8_t> vars; // small variable storage
    string persistentFile;
};

// -------------------- HELPER FUNCTIONS --------------------
int binaryStringToInt(const string &bin) {
    return stoi(bin, nullptr, 2);
}

string intToBinaryString(uint8_t val) {
    string s;
    for (int i = 7; i >=0; i--) {
        s += ((val >> i) & 1) ? '1' : '0';
    }
    return s;
}

vector<string> tokenize(const string &line) {
    vector<string> tokens;
    istringstream iss(line);
    string tok;
    while (iss >> tok) tokens.push_back(tok);
    return tokens;
}

void savePersistent(Context &ctx) {
    ofstream ofs(ctx.persistentFile, ios::binary);
    for (uint8_t val : ctx.memory) ofs.put(val);
}

// -------------------- OPCODE HANDLERS --------------------
void handleMove(Context &ctx, const vector<string> &args) {
    if (args.size() < 2) { cout << "[ERROR] MOVE needs 2 args\n"; return; }
    int src = binaryStringToInt(args[0]);
    int dst = binaryStringToInt(args[1]);

    if (args[1][0] == '1') { // turn to int
        ctx.memory[dst] = src - binaryStringToInt("10000000");
        cout << "output is an int \n";
    } else {
        ctx.memory[dst] = ctx.memory[src];
    }
    if (src >= ctx.memory.size() || dst >= ctx.memory.size()) { cout << "[ERROR] MOVE out of bounds\n"; return; }
    cout << "[EXEC] MOVE mem[" << dst << "] = mem[" << src << "] (" << (int)ctx.memory[dst] << ")\n";
}

void handleRead(Context &ctx, const vector<string> &args) {
    if (args.empty()) { cout << "[ERROR] READ needs target arg\n"; return; }
    int dst = binaryStringToInt(args[0]);
    if (dst >= ctx.memory.size()) { cout << "[ERROR] READ out of bounds\n"; return; }
    string input;
    cout << "Enter 0 or 1: ";
    getline(cin, input);
    input.erase(remove_if(input.begin(), input.end(), ::isspace), input.end());
    if (input.empty() || (input[0] != '0' && input[0] != '1')) input = "0";
    ctx.memory[dst] = input[0] - '0';
    cout << "[EXEC] READ mem[" << dst << "] = " << (int)ctx.memory[dst] << "\n";
}

void handleWrite(Context &ctx, const vector<string> &args) {
    if (args.empty()) { cout << "[ERROR] WRITE needs source arg\n"; return; }
    int src = binaryStringToInt(args[0]);
    if (src >= ctx.memory.size()) { cout << "[ERROR] WRITE out of bounds\n"; return; }
    cout << "[EXEC] WRITE mem[" << src << "] = " << (int)ctx.memory[src] << "\n";
}

void handleIfEqual(Context &ctx, const vector<string> &args, int &lineNum) {
    if (args.size() < 3) { cout << "[ERROR] IF needs 3 args\n"; return; }
    int a = binaryStringToInt(args[0]);
    int b = binaryStringToInt(args[1]);
    int target = binaryStringToInt(args[2]);
    if (a >= ctx.memory.size() || b >= ctx.memory.size()) { cout << "[ERROR] IF out of bounds\n"; return; }
    if (ctx.memory[a] == ctx.memory[b]) lineNum = target - 1;
}

void handleIfGE(Context &ctx, const vector<string> &args, int &lineNum) {
    if (args.size() < 3) { cout << "[ERROR] IFGE needs 3 args\n"; return; }
    int a = binaryStringToInt(args[0]);
    int b = binaryStringToInt(args[1]);
    int target = binaryStringToInt(args[2]);
    if (a >= ctx.memory.size() || b >= ctx.memory.size()) { cout << "[ERROR] IFGE out of bounds\n"; return; }
    if (ctx.memory[a] >= ctx.memory[b]) lineNum = target -1;
}

void handleIfLE(Context &ctx, const vector<string> &args, int &lineNum) {
    if (args.size() < 3) { cout << "[ERROR] IFLE needs 3 args\n"; return; }
    int a = binaryStringToInt(args[0]);
    int b = binaryStringToInt(args[1]);
    int target = binaryStringToInt(args[2]);
    if (a >= ctx.memory.size() || b >= ctx.memory.size()) { cout << "[ERROR] IFLE out of bounds\n"; return; }
    if (ctx.memory[a] <= ctx.memory[b]) lineNum = target -1;
}

void handleIfGT(Context &ctx, const vector<string> &args, int &lineNum) {
    if (args.size() < 3) { cout << "[ERROR] IFGT needs 3 args\n"; return; }
    int a = binaryStringToInt(args[0]);
    int b = binaryStringToInt(args[1]);
    int target = binaryStringToInt(args[2]);
    if (a >= ctx.memory.size() || b >= ctx.memory.size()) { cout << "[ERROR] IFGT out of bounds\n"; return; }
    if (ctx.memory[a] > ctx.memory[b]) lineNum = target -1;
}

void handleIfLT(Context &ctx, const vector<string> &args, int &lineNum) {
    if (args.size() < 3) { cout << "[ERROR] IFLT needs 3 args\n"; return; }
    int a = binaryStringToInt(args[0]);
    int b = binaryStringToInt(args[1]);
    int target = binaryStringToInt(args[2]);
    if (a >= ctx.memory.size() || b >= ctx.memory.size()) { cout << "[ERROR] IFLT out of bounds\n"; return; }
    if (ctx.memory[a] < ctx.memory[b]) lineNum = target -1;
}

void handleIfNE(Context &ctx, const vector<string> &args, int &lineNum) {
    if (args.size() < 3) { cout << "[ERROR] IFNE needs 3 args\n"; return; }
    int a = binaryStringToInt(args[0]);
    int b = binaryStringToInt(args[1]);
    int target = binaryStringToInt(args[2]);
    if (a >= ctx.memory.size() || b >= ctx.memory.size()) { cout << "[ERROR] IFNE out of bounds\n"; return; }
    if (ctx.memory[a] != ctx.memory[b]) lineNum = target -1;
}

void handleRunMemory(Context &ctx, const vector<string> &args) {
    cout << "[EXEC] RUN from memory placeholder\n";
}

void handlePersistentLoad(Context &ctx, const vector<string> &args) {
    ifstream ifs(ctx.persistentFile, ios::binary);
    if (!ifs) { cout << "[ERROR] Persistent file not found\n"; return; }
    ifs.read((char*)ctx.memory.data(), ctx.memory.size());
    cout << "[EXEC] Loaded persistent memory from " << ctx.persistentFile << "\n";
}

void handlePersistentSave(Context &ctx, const vector<string> &args) {
    savePersistent(ctx);
    cout << "[EXEC] Saved persistent memory to " << ctx.persistentFile << "\n";
}

void handleWait(Context &ctx, const vector<string> &args) {
    if (args.empty()) return;
    int sec = binaryStringToInt(args[0]);
    cout << "[EXEC] WAIT " << sec << " sec\n";
    this_thread::sleep_for(chrono::seconds(sec));
}

void handleThreading(Context &ctx, const vector<string> &args) {
    cout << "[EXEC] THREADING placeholder\n";
}

// -------------------- OPCODE REGISTRY --------------------
struct Opcode {
    function<void(Context&, const vector<string>&)> handler;
    bool conditional = false; // for if ops needing lineNum reference
};

unordered_map<string, Opcode> opcodeMap;

void registerOpcodes() {
    opcodeMap["00000001"] = {handleMove};
    opcodeMap["00000010"] = {handleRead};
    opcodeMap["00000011"] = {handleWrite};
    opcodeMap["00100001"] = {[](Context& ctx, const vector<string>& args){ cout << "[ERROR] IF requires line control\n"; }};
    opcodeMap["00100010"] = {[](Context& ctx, const vector<string>& args){ cout << "[ERROR] IFGE requires line control\n"; }};
    opcodeMap["00100011"] = {[](Context& ctx, const vector<string>& args){ cout << "[ERROR] IFLE requires line control\n"; }};
    opcodeMap["00100110"] = {[](Context& ctx, const vector<string>& args){ cout << "[ERROR] IFGT requires line control\n"; }};
    opcodeMap["00100111"] = {[](Context& ctx, const vector<string>& args){ cout << "[ERROR] IFLT requires line control\n"; }};
    opcodeMap["00100101"] = {[](Context& ctx, const vector<string>& args){ cout << "[ERROR] IFNE requires line control\n"; }};
    opcodeMap["00001111"] = {handleRunMemory};
    opcodeMap["00001010"] = {handlePersistentLoad};
    opcodeMap["00010101"] = {handlePersistentSave};
    opcodeMap["01001010"] = {handleWait};
    opcodeMap["01011111"] = {handleThreading};
}

// -------------------- EXECUTION --------------------
void executeLine(Context &ctx, const vector<string> &tokens, int &lineNum) {
    if (tokens.empty()) return;
    string op = tokens[0];
    vector<string> args(tokens.begin()+1, tokens.end());

    // Handle conditional if opcodes
    if (op == "00100001") handleIfEqual(ctx, args, lineNum);
    else if (op == "00100010") handleIfGE(ctx, args, lineNum);
    else if (op == "00100011") handleIfLE(ctx, args, lineNum);
    else if (op == "00100110") handleIfGT(ctx, args, lineNum);
    else if (op == "00100111") handleIfLT(ctx, args, lineNum);
    else if (op == "00100101") handleIfNE(ctx, args, lineNum);
    else {
        auto it = opcodeMap.find(op);
        if (it != opcodeMap.end()) it->second.handler(ctx, args);
        else cout << "[ERROR] Unknown opcode: " << op << "\n";
    }
}

// -------------------- REPL & FILE RUN --------------------
void repl(Context &ctx) {
    string line;
    while (true) {
        cout << "bh> ";
        if (!getline(cin, line)) break;
        auto tokens = tokenize(line);
        if (!tokens.empty()) {
            if (tokens[0] == "help") {
                cout << "BitHavoc Help:\n";
                cout << "Opcodes:\n";
                cout << "00000001 -> move something somewhere\n";
                cout << "00000010 -> read 1 bit from user\n";
                cout << "00000011 -> write memory to screen\n";
                cout << "00100001 -> if equal ...\n";
                cout << "00100010 -> if >= ...\n";
                cout << "00100011 -> if <= ...\n";
                cout << "00100110 -> if > ...\n";
                cout << "00100111 -> if < ...\n";
                cout << "00100101 -> if != ...\n";
                cout << "00001111 -> run from memory\n";
                cout << "00001010 -> load from persistent memory\n";
                cout << "00010101 -> save to persistent memory\n";
                cout << "01001010 -> wait seconds\n";
                cout << "01011111 -> threading placeholder\n";
            continue;
            }
        }
        if (!tokens.empty()) { 
            if (tokens[0] == "exit") {
                break; 
            }
        }

        int dummyLine = 0;
        executeLine(ctx, tokens, dummyLine);
    }
}

void runFile(Context &ctx, const string &filename) {
    ifstream ifs(filename);
    if (!ifs) { cout << "[ERROR] File not found: " << filename << "\n"; return; }
    vector<string> lines;
    string line;
    while (getline(ifs, line)) lines.push_back(line);

    for (int i=0; i<lines.size(); i++) {
        auto tokens = tokenize(lines[i]);
        executeLine(ctx, tokens, i);
    }
}

// -------------------- MAIN --------------------
int main() {
    registerOpcodes();
    Context ctx;

    cout << "=== BitHavoc C++ Shell ===\n";
    cout << "Enter memory size (bytes): ";
    int memSize;
    cin >> memSize;
    ctx.memory.resize(memSize, 0);
    cin.ignore();

    cout << "Enter persistent storage file path: ";
    getline(cin, ctx.persistentFile);

    cout << "Select mode:\n1 = run .bh file\n2 = REPL\nChoice: ";
    int mode; cin >> mode; cin.ignore();

    if (mode == 1) {
        string filename;
        cout << "Enter .bh filename: ";
        getline(cin, filename);
        runFile(ctx, filename);
    } else {
        cout << "Starting REPL (type 'exit' to quit)\n";
        repl(ctx);
    }

    cout << "Saving persistent storage before exit...\n";
    savePersistent(ctx);
    cout << "Bye!\n";
    return 0;
}

