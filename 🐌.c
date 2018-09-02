//cc -D_POSIX_C_SOURCE=200809L -pedantic 🐌.c -O3 -o snail
/*
    Snail Shell
    
    A shell for POSIX that hopefully isn't as slow as its namesake.
    
    C
    --
    This is free and unencumbered software released into the public domain.
    Anyone is free to copy, modify, publish, use, compile, sell, or
    distribute this software, either in source code form or as a compiled
    binary, for any purpose, commercial or non-commercial, and by any
    means.
    In jurisdictions that recognize copyright laws, the author or authors
    of this software dedicate any and all copyright interest in the
    software to the public domain. We make this dedication for the benefit
    of the public at large and to the detriment of our heirs and
    successors. We intend this dedication to be an overt act of
    relinquishment in perpetuity of all present and future rights to this
    software under copyright law.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
    OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
    ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
    OTHER DEALINGS IN THE SOFTWARE.
    For more information, please refer to <http://unlicense.org/>
*/
//C STD
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

//POSIX
#include <unistd.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>

#define forever for(;;)

const ssize_t maxLine = 80;
const size_t maxHistory = 10;
volatile pid_t runningChild = 0;

struct LinkedList {
    struct LinkedList* next;
    struct LinkedList* previous;
    char** arguments;
};

void handleSIGINT(int dummy); //Handles Ctrl+C
void printCommand(char** arguments); //Prints a command
void printPrompt();
ssize_t processArguments(char** line, ssize_t *size, char** arguments); //Processes arguments

int main(int argc, char* argv[])
{
    signal(SIGINT, handleSIGINT);

    runningChild = 0;

    char** arguments;

    struct LinkedList* history = malloc(sizeof(struct LinkedList));    
    int historyTracker = 0;
    history->next = NULL;
    history->previous = NULL;
    history->arguments = NULL;

    struct LinkedList* historyTail = history;

    char* line = NULL;
    size_t lineSize = maxLine;
    
    bool execute = true;

    forever {
        execute = true;

        printPrompt();

        arguments = malloc(sizeof(char*) * (maxLine / 2 - 1));

        // Get input
        ssize_t size = getline(&line, &lineSize, stdin);

        // Check Ctrl+D
        if (feof(stdin)) {
            printf("exit\n");
            exit(0);
        }

        // Process Input
        if (size >= maxLine) {
            fprintf(stderr, "🐌  Maximum line size exceeded. (%li/%li)\n", size, maxLine);
            continue;
        }

        ssize_t count = processArguments(&line, &size, arguments);

        if (count <= 0) {
            continue;
        }
        
        // Check if asynchronous
        bool asynchronous = (strcmp(arguments[count - 1], "&") == 0);
        if (asynchronous) {
            arguments[count - 1] = NULL;
            count -= 1;
            if (count <= 0) {
                continue;
            }            
        }
        
        // Shell builtins
        // recollection (first so shell builtins can also be used)
        if (arguments[0][0] == '!') {
            if (count > 1) {
<<<<<<< HEAD
                fprintf(stderr, "🐌  A lot of arguments for history recollection.\n");
=======
                fprintf(stderr, "🐌  Invalid argument count for history recollection.\n");
>>>>>>> shell_change
                continue;
            }
            if (arguments[0][1] ==  '!') {
                arguments = NULL;
                if (history->next) {
                    arguments = history->next->arguments;
                    printCommand(arguments);
                } else {
                    fprintf(stdout, "🐌  No commands in history.\n");
                    continue;
                }
            } else {
                int historyCount;
                if (sscanf(arguments[0], "!%i", &historyCount) != EOF) {
                    struct LinkedList* tracker = history;
                    for (ssize_t i = 1; i <= historyCount; i++) {
                        tracker = tracker->next;
                        if (tracker == NULL) {
                            break;
                        }
                    }
                    if (tracker == NULL) {
                        fprintf(stdout, "🐌  No such command in history.\n");
                        continue;
                    }
                    arguments = tracker->arguments;
                    printCommand(arguments);
                }
            }
        }
        
        // exit 
        if (strcmp(arguments[0], "exit") == 0) {
            if (count <= 1) {
                return 0;                
            } else {
                fprintf(stderr, "🐌  Invalid argument count for exit.\n");
                continue;
            }
        }

        // history
        if (strcmp(arguments[0], "history") == 0) {
            execute = false;
            if (count > 1) {
                fprintf(stderr, "🐌  Invalid argument count for history.\n");
                continue;
            } else {
                struct LinkedList* iterator = history->next;
                int tempTracker = historyTracker;
                while (iterator != NULL) {
                    fprintf(stdout, "%i ", tempTracker--);
                    printCommand(iterator->arguments);
                    iterator = iterator->next;
                }
            }
        }
        
        // cd 
        if (strcmp(arguments[0], "cd") == 0) {
            execute = false;
            if (count == 2) {
                if(chdir(arguments[1])) {
                    fprintf(stderr, "🐌  Failed to change directory.\n");
                }
            } else if (count == 1) {
                if (chdir(getenv("HOME"))) {
                    fprintf(stderr, "🐌  Failed to change directory.\n");
                }
            } else {
                fprintf(stderr, "🐌  Invalid number of arguments for cd. [%li/1]\n", count - 1);
                continue;
            }
        }

        fflush(stdout);

        // Execution
        if (execute) {
            pid_t processID = fork();

            if (processID < 0) {
                fprintf(stderr, "🐌  Failed to fork.\n");
            } else if (processID == 0) {
                int status = execvp(arguments[0], arguments);
                if (status == -1) {
                    fprintf(stderr, "🐌  Unknown command '%s'.\n", arguments[0]);
                    exit(64);
                }
            } else {
                if (!asynchronous) {
                    runningChild = processID;
                    waitpid(runningChild, NULL, 0);
                    runningChild = 0;
                }
            }
        }

        // Rewriting History
        history->arguments = arguments;
        struct LinkedList* new = malloc(sizeof(struct LinkedList));
        new->next = history;
        history->previous = new;
        new->arguments = NULL;
        history = new;
        historyTracker += 1;

        if (historyTracker > maxHistory) {
            struct LinkedList* freeable = historyTail;
            historyTail = historyTail->previous;
            historyTail->next = NULL;
            size_t i = 0;
            char* iterator = freeable->arguments[i];
            while (iterator != NULL) {
                free(iterator);
                iterator = freeable->arguments[++i];
            }
            free(freeable->arguments);

            free(freeable);
        }
    }
}

void handleSIGINT(int dummy) {
    if (runningChild) {
        if (kill(runningChild, 0)) {
            runningChild = 0;
        }
    } else {
        size_t _ = write(0, "\n", 1);
        printPrompt();
        fflush(stdin);
        fflush(stdout);
    }
}

void printCommand(char** arguments) {
    ssize_t i = 0;
    char* iterator = arguments[i];
    while (iterator != NULL) {
        fprintf(stdout, "%s ", iterator);
        iterator = arguments[++i];
    }
    fprintf(stdout, "\n");
}

void printPrompt() {
    char cwdBuffer[1024];
    // Get CWD
    char* cwd =  getcwd(cwdBuffer, 1024);
    cwd = cwd? cwd: "osh";

    const char* home = getenv("HOME");
    char* search = strstr(cwd, home);
    if (search) {
        size_t length = strlen(home);
        search[length - 1] = '~';
        cwd = &search[length - 1];
    }

    // Prompt
    fprintf(stdout, "🐌  \x1B[35m%s\x1B[34m$\x1B[0m ", cwd);
    fflush(stdout);
}

ssize_t processArguments(char** line, ssize_t *size, char** arguments)
{
    ssize_t j = 0;
    ssize_t k = 0;
    bool onArgument = false;

    for (size_t i = 0; i < *size; i++) {
        
        if (((*line)[i] == ' ') || ((*line)[i] == '\n'))  {
            if (onArgument) {
                onArgument = false;
                arguments[j++][k] = 0;
                k = 0; 
            }
        } else {
            if (!onArgument) {
                onArgument = true;
                arguments[j] = malloc(sizeof(char) * maxLine / 2 + 1);
            }
            arguments[j][k++] = (*line)[i];
        }
    }

    ssize_t count = j + (onArgument? 1: 0);
    arguments[count] = NULL;
    return count;
}

