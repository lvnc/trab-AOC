#include <stdio.h>
#include <math.h>

void main() {

	printf("Duracao da Partida de Xadrez\n\n");


	int hi, hf, duracao;

	printf("Hora de inicio: ");
	scanf("%d", &hi);

	printf("Hora de fim: ");
	scanf("%d", &hf);


	if (hi > hf) {
		duracao = (24 - hi) + hf;
	} 
	else if (hi == hf) {
		duracao = 24;
	}
	else {
		duracao = hf - hi;
	}

	printf("Duracao: %d horas \n\n", duracao);

	system("pause");

}
