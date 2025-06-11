import 'dotenv/config';
import { getRPSChoices } from '../Core/game.js';
import { capitalize, InstallGlobalCommands } from '../Core/utils.js';

// Get the game choices from game.js
function createCommandChoices() {
  const choices = getRPSChoices();
  const commandChoices = [];

  for (let choice of choices) {
    commandChoices.push({
      name: capitalize(choice),
      value: choice.toLowerCase(),
    });
  }

  return commandChoices;
}

// Simple test command
const TEST_COMMAND = {
  name: 'test',
  description: 'Basic command',
  type: 1,
  integration_types: [0, 1],
  contexts: [0, 1, 2],
};

// Command containing options
const CHALLENGE_COMMAND = {
  name: 'challenge',
  description: 'Challenge to a match of rock paper scissors',
  options: [
    {
      type: 3,
      name: 'object',
      description: 'Pick your object',
      required: true,
      choices: createCommandChoices(),
    },
  ],
  type: 1,
  integration_types: [0, 1],
  contexts: [0, 2],
};

const MENU_COMMAND = {
  name: 'menu',
  description: 'Lihat menu dari toko berdasarkan ID',
  options: [
    {
      name: 'store_name',
      description: 'ID toko (1-7)',
      type: 4, // INTEGER
      required: true,
      choices: [
        { name: 'Nasi Goreng & Mie',  value: 1 },
        { name: 'Dapur Ummi Asti',    value: 2 },
        { name: 'Lalapan Mbak Eli',   value: 3 },
        { name: 'Amazing Mie',        value: 4 },
        { name: 'Warung Bu Mimin',    value: 5 },
        { name: 'Aneka Minuman',      value: 6 },
        { name: 'Aneka Jajan',        value: 7 },
      ],
    },
  ],
  type: 1,
};

const ADD_ORDER_COMMAND = {
  name: "addOrder",
  description: "Menambahkan pesanan",
  options: [
    {
      name: 'store_name',
      description: 'ID toko (1-7)',
      type: 4, // INTEGER
      required: true,
      choices: [
        { name: 'Nasi Goreng & Mie',  value: 1 },
        { name: 'Dapur Ummi Asti',    value: 2 },
        { name: 'Lalapan Mbak Eli',   value: 3 },
        { name: 'Amazing Mie',        value: 4 },
        { name: 'Warung Bu Mimin',    value: 5 },
        { name: 'Aneka Minuman',      value: 6 },
        { name: 'Aneka Jajan',        value: 7 }
      ],
      options: [
        {
          name: 'store_name',
          description: 'ID toko (1-7)',
          type: 4, // INTEGER
          required: true,
          choices: [
            { name: 'Nasi Goreng & Mie',  value: 1 },
            { name: 'Dapur Ummi Asti',    value: 2 },
            { name: 'Lalapan Mbak Eli',   value: 3 },
            { name: 'Amazing Mie',        value: 4 },
            { name: 'Warung Bu Mimin',    value: 5 },
            { name: 'Aneka Minuman',      value: 6 },
            { name: 'Aneka Jajan',        value: 7 }
          ]
        }
      ]
    }
  ]
}

const ALL_COMMANDS = [TEST_COMMAND, CHALLENGE_COMMAND, MENU_COMMAND, ADD_ORDER_COMMAND];

InstallGlobalCommands(process.env.APP_ID, ALL_COMMANDS);
