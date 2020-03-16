SRC = ./src/main.cpp
NAME = Raytracer

CC = g++

RM = rm -f

OBJ = $(SRC:.cpp=.o)

CFLAGS = -O2 -W -Wall -Wextra -Werror
CFLAGS += -I./src/Vec3.h

all : $(NAME)

$(NAME) : $(OBJ)
	$(CC) $(SRC) -o $(NAME) $(OBJ)

clean :
	$(RM) $(OBJ)

fclean : clean
	$(RM) $(NAME)

re : fclean all

.PHONY : all clean fclean re