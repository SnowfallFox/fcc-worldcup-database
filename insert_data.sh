#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams")
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART")
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS OPP_GOALS
do
# teams just needs the names of all the teams
# games needs: year, round, winner_id, opponent_id, winner_goals, opp_goals
# where winner and opp ids are just their team ids
  if [[ $YEAR != "year" ]]
  then
    # check winner/opp team_id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    #if not found
    if [[ -z $WINNER_ID ]]
    then
      #insert team
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
    fi
    if [[ -z $OPP_ID ]]
    then
      #insert team
      INSERT_OPP=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPP == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
    fi
  fi
    #get new winner/opp_id for games
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    #insert all into games
    INSERT_GAME=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPP_ID, $W_GOALS, $OPP_GOALS)")
done